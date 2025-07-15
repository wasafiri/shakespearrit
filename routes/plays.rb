module PlaysRoutes
  def self.load(r)
    r.hash_branch "plays" do |r|
      # List all plays (GET /plays)
      r.is do
        begin
          @plays = Play.order(:title).all
          view("plays/index")
        rescue Sequel::Error => e
          logger.error "Database error in plays index: #{e.message}"
          flash["error"] = "Unable to load plays"
          r.redirect("/")
        end
      end

      # Routes for individual play
      r.on Integer do |play_id|
        # Load play or halt with 404
        begin
          @play = Play[play_id] or r.halt(404, "Play not found")
        rescue Sequel::Error => e
          logger.error "Database error loading play #{play_id}: #{e.message}"
          r.halt(500, "Error loading play")
        end

        # Show play details (GET /plays/:play_id)
        r.is do
          begin
            @acts = @play.acts_dataset.order(:act_number).all
            view("plays/show_play")
          rescue Sequel::Error => e
            logger.error "Error loading acts for play #{play_id}: #{e.message}"
            flash["error"] = "Unable to load play details"
            r.redirect("/plays")
          end
        end

        # Routes for acts within a play
        r.on "acts", Integer do |act_id|
          begin
            @act = @play.acts_dataset[act_id: act_id] or r.halt(404, "Act not found")
          rescue Sequel::Error => e
            logger.error "Error loading act #{act_id}: #{e.message}"
            r.halt(500, "Error loading act")
          end

          # Routes for scenes within an act
          r.on "scenes", Integer do |scene_id|
            begin
              @scene = @act.scenes_dataset[scene_id: scene_id] or r.halt(404, "Scene not found")
            rescue Sequel::Error => e
              logger.error "Error loading scene #{scene_id}: #{e.message}"
              r.halt(500, "Error loading scene")
            end

            # Show scene details (GET /plays/:play_id/acts/:act_id/scenes/:scene_id)
            r.is do
              begin
                @speeches = @scene.speeches_dataset.order(:order_in_scene).all
                view("plays/show_scene")
              rescue Sequel::Error => e
                logger.error "Error loading speeches for scene #{scene_id}: #{e.message}"
                flash["error"] = "Unable to load scene details"
                r.redirect("/plays/#{play_id}/acts/#{act_id}")
              end
            end

            # Routes for speeches within a scene
            r.on "speeches", Integer do |speech_id|
              begin
                @speech = @scene.speeches_dataset[speech_id: speech_id] or r.halt(404, "Speech not found")
              rescue Sequel::Error => e
                logger.error "Error loading speech #{speech_id}: #{e.message}"
                r.halt(500, "Error loading speech")
              end

              # Show speech details (GET /plays/:play_id/acts/:act_id/scenes/:scene_id/speeches/:speech_id)
              r.is do
                begin
                  @lines = @speech.speech_lines_dataset.order(:start_line_number).all
                  @interpretations_by_line = @lines.each_with_object({}) do |line, hash|
                    hash[line.id] = line.interpretations_dataset.eager(:user).all
                  end
                  view("plays/show_speech")
                rescue Sequel::Error => e
                  logger.error "Error loading lines for speech #{speech_id}: #{e.message}"
                  flash["error"] = "Unable to load speech details"
                  r.redirect("/plays/#{play_id}/acts/#{act_id}/scenes/#{scene_id}")
                end
              end
            end
          end
        end
      end
    end
  end
end