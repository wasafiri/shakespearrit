class ShakespeareApp
  route("admin") do |r|
    # Authentication & Authorization
    require_login!
    require_admin!

    r.on "plays" do
      # GET /admin/plays - List all plays
      r.is do
        r.get do
          @plays = Play.order(Sequel.asc(:title)).all
          view("admin/plays/index")
        end
      end

      # Routes for specific play
      r.on Integer do |play_id|
        @play = Play[play_id] or r.halt(404, "Play not found")

        # GET /admin/plays/:play_id - Show play details
        r.is do
          r.get do
            @acts = @play.acts_dataset.order(:act_number).all
            view("admin/plays/show_play")
          end
        end
      end
    end
    
    # Admin Dashboard
    r.is do
      r.get do
        @all_users = User.order(Sequel.desc(:created_at)).all
        @all_interps = Interpretation.order(Sequel.desc(:created_at)).limit(50).all
        @stats = {
          total_users: User.count,
          total_plays: Play.count,
          total_interpretations: Interpretation.count,
          recent_interpretations: Interpretation.where { created_at > Time.now - 7*24*60*60 }.count
        }
        view("admin/index")
      end
    end
  end
end
