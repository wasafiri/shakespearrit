Sequel.migration do
    change do
      create_table(:achievements) do
        primary_key :id
        String :name, null: false
        String :description
        String :badge_icon  # CSS class for the badge icon
        DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      end
  
      create_table(:user_achievements) do
        primary_key :id
        foreign_key :user_id, :users, on_delete: :cascade
        foreign_key :achievement_id, :achievements, on_delete: :cascade
        DateTime :earned_at, default: Sequel::CURRENT_TIMESTAMP
        index [:user_id, :achievement_id], unique: true
      end
    end
  end