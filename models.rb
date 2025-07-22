require_relative "db"
require "sequel"
require "bcrypt"
Sequel.extension :inflector # For .constantize in custom polymorphic associations

# Sequel model classes

class User < Sequel::Model
  plugin :timestamps, update_on_create: true
  plugin :validation_helpers
  plugin :json_serializer, naked: true # Allow mass assignment for all columns in tests

  one_to_many :interpretations
  one_to_many :ratings
  one_to_many :comments

  attr_accessor :youtube_refresh_token

  def validate
    super
    validates_presence [:email, :password_digest]
    validates_unique :email
    validates_format(/\A[^@\s]+@[^@\s]+\z/, :email, message: 'must be a valid email address')
  end

  def recent_activity(limit = 10)
    interpretations_dataset
      .order(Sequel.desc(:created_at))
      .limit(limit)
  end

  def has_rated?(interpretation)
    ratings_dataset.where(interpretation_id: interpretation.id).count > 0
  end

  # For password encryption using bcrypt:
  def password=(new_password)
    self.password_digest = BCrypt::Password.create(new_password)
  end

  def valid_password?(attempt)
    return false if password_digest.nil?
    BCrypt::Password.new(password_digest) == attempt
  end
end

class Achievement < Sequel::Model
  one_to_many :user_achievements
  many_to_many :users, join_table: :user_achievements

  BADGES = {
    first_interpretation: {
      name: "First ASL",
      description: "Posted your first ASL interpretation",
      badge_icon: "badge-first-post"
    },
    interpretation_star: {
      name: "Interpretation Star",
      description: "Posted 10 interpretations",
      badge_icon: "badge-star"
    },
    shakespeare_scholar: {
      name: "Shakespeare Scholar",
      description: "Posted interpretations from 5 different plays",
      badge_icon: "badge-scholar"
    }
  }

  def self.check_achievements_for(user)
    # Check First Interpretation
    if user.interpretations.count == 1
      award_achievement(user, :first_interpretation)
    end

    # Check Interpretation Star
    if user.interpretations.count >= 10
      award_achievement(user, :interpretation_star)
    end

    # Check Shakespeare Scholar
    unique_plays = user.interpretations.map(&:play).compact.uniq
    if unique_plays.length >= 5
      award_achievement(user, :shakespeare_scholar)
    end
  end

  private

  def self.award_achievement(user, badge_key)
    badge = BADGES[badge_key]
    achievement = Achievement.find_or_create(name: badge[:name]) do |a|
      a.description = badge[:description]
      a.badge_icon = badge[:badge_icon]
    end
    
    unless UserAchievement.where(user_id: user.id, achievement_id: achievement.id).any?
      UserAchievement.create(user_id: user.id, achievement_id: achievement.id)
    end
  end
end

class UserAchievement < Sequel::Model
  many_to_one :user
  many_to_one :achievement
end

class Play < Sequel::Model
  plugin :timestamps, update_on_create: true
  plugin :validation_helpers
  one_to_many :acts

  # Scope for searching plays
  def self.search(query)
    where(Sequel.ilike(:title, "%#{query}%") | Sequel.ilike(:author, "%#{query}%"))
  end

  def validate
    super
    validates_presence [:title]
    validates_unique :title
  end
end

class Act < Sequel::Model
  plugin :timestamps, update_on_create: true
  many_to_one :play
  one_to_many :scenes
end

class Scene < Sequel::Model
  plugin :timestamps, update_on_create: true
  many_to_one :act
  one_to_many :speeches
  one_to_many :additional_lines
end

class Speech < Sequel::Model
  plugin :timestamps, update_on_create: true
  many_to_one :scene
  one_to_many :speech_lines
end

class SpeechLine < Sequel::Model
  plugin :timestamps, update_on_create: true
  plugin :validation_helpers
  many_to_one :speech
  one_to_many :line_versions
  one_to_many :interpretations, key: :interpretable_id, reciprocal: :interpretable, conditions: {interpretable_type: 'SpeechLine'},
    adder: lambda{|interp| interp.update(interpretable_id: pk, interpretable_type: 'SpeechLine')},
    remover: lambda{|interp| interp.update(interpretable_id: nil, interpretable_type: nil)},
    clearer: lambda{interpretations_dataset.update(interpretable_id: nil, interpretable_type: nil)}

  def validate
    super
    validates_presence [:speech_id, :text]
  end

  def play
    speech.scene.act.play
  end
end

class ScholarSource < Sequel::Model
  plugin :timestamps, update_on_create: true
  one_to_many :line_versions
  one_to_many :additional_lines
end

class LineVersion < Sequel::Model
  plugin :timestamps, update_on_create: true
  many_to_one :speech_line
  many_to_one :scholar_source
  one_to_many :interpretations, key: :interpretable_id, reciprocal: :interpretable, conditions: {interpretable_type: 'LineVersion'},
    adder: lambda{|interp| interp.update(interpretable_id: pk, interpretable_type: 'LineVersion')},
    remover: lambda{|interp| interp.update(interpretable_id: nil, interpretable_type: nil)},
    clearer: lambda{interpretations_dataset.update(interpretable_id: nil, interpretable_type: nil)}

  def play
    speech_line.play
  end
end

class AdditionalLine < Sequel::Model
  plugin :timestamps, update_on_create: true
  many_to_one :scene
  many_to_one :scholar_source
  many_to_one :position_reference_line, class: :SpeechLine, key: :position_reference_line_id
  one_to_many :interpretations, key: :interpretable_id, reciprocal: :interpretable, conditions: {interpretable_type: 'AdditionalLine'},
    adder: lambda{|interp| interp.update(interpretable_id: pk, interpretable_type: 'AdditionalLine')},
    remover: lambda{|interp| interp.update(interpretable_id: nil, interpretable_type: nil)},
    clearer: lambda{interpretations_dataset.update(interpretable_id: nil, interpretable_type: nil)}

  def play
    scene.act.play
  end
end

class Interpretation < Sequel::Model
  plugin :timestamps, update_on_create: true
  plugin :validation_helpers
  plugin :json_serializer, naked: true # Allow mass assignment for all columns in tests
  many_to_one :user
  many_to_one :interpretable, reciprocal: :interpretations, reciprocal_type: :one_to_many,
    setter: (lambda do |interpretable_obj|
      self[:interpretable_id] = (interpretable_obj.pk if interpretable_obj)
      self[:interpretable_type] = (interpretable_obj.class.name if interpretable_obj)
    end),
    dataset: (proc do
      return unless interpretable_type && interpretable_id
      klass = interpretable_type.constantize
      klass.where(klass.primary_key => interpretable_id)
    end),
    eager_loader: (lambda do |eo|
      id_map = {}
      eo[:rows].each do |interp|
        interp.associations[:interpretable] = nil
        if interp.interpretable_type && interp.interpretable_id
          ((id_map[interp.interpretable_type] ||= {})[interp.interpretable_id] ||= []) << interp
        end
      end
      id_map.each do |klass_name, id_map_for_class|
        klass = klass_name.constantize
        klass.where(klass.primary_key => id_map_for_class.keys).all do |interpretable_obj|
          id_map_for_class[interpretable_obj.pk].each do |interp|
            interp.associations[:interpretable] = interpretable_obj
          end
        end
      end
    end)

  one_to_many :ratings
  one_to_many :comments
  many_to_one :source_interpretation, class: self, key: :source_interpretation_id
  one_to_many :forks, key: :source_interpretation_id, class: self

  def play
    interpretable.play if interpretable.respond_to?(:play)
  end

  def average_rating
    return 0 if ratings.empty?
    (ratings.sum(:stars) / ratings.count.to_f).round(2)
  end

  def validate
    super
    validates_presence [:youtube_video_id, :status, :interpretable_id, :interpretable_type]
    validates_includes ['pending', 'approved', 'rejected'], :status
  end
end

class Rating < Sequel::Model
  plugin :timestamps, update_on_create: true
  plugin :validation_helpers
  many_to_one :user
  many_to_one :interpretation

  def validate
    super
    validates_presence [:user_id, :interpretation_id, :stars]
    validates_includes (1..5), :stars
    validates_unique [:user_id, :interpretation_id], message: 'has already rated this interpretation'
  end
end

class Comment < Sequel::Model
  plugin :timestamps, update_on_create: true
  plugin :validation_helpers
  many_to_one :user
  many_to_one :interpretation
  many_to_one :parent_comment, class: self
  one_to_many :replies, key: :parent_comment_id, class: self

  def validate
    super
    validates_presence [:user_id, :interpretation_id, :body]
  end
end
