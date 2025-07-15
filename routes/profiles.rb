module ProfilesRoutes
    def self.load(r)
      r.on "profiles", String do |username|
        @user = User.first(display_name: username) or r.halt(404, "User not found")
        
        # GET /profiles/:username
        r.get do
          @interpretations = @user.interpretations_dataset.order(Sequel.desc(:created_at))
          @achievements = @user.achievements
          view("profiles/show")
        end
      end
    end
  end