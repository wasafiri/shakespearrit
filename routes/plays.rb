class ShakespeareApp
  route("plays") do |r|
    # GET /plays - List all plays
    r.is do
      r.get do
        @plays = Play.order(:title).all
        view("plays/index")
      end
    end

    # Routes for specific play
    r.on Integer do |play_id|
      @play = Play[play_id] or r.halt(404, "Play not found")

      # GET /plays/:id - Show play with acts
      r.is do
        r.get do
          @acts = @play.acts_dataset.order(:act_number).all
          view("plays/show_play")
        end
      end

      # Routes for acts within a play
      r.on "acts", Integer do |act_id|
        @act = Act.where(play_id: @play.id, id: act_id).first or r.halt(404, "Act not found")

        # GET /plays/:play_id/acts/:act_id - Show act with scenes
        r.is do
          r.get do
            @scenes = @act.scenes_dataset.order(:scene_number).all
            view("plays/show_act")
          end
        end

        # Routes for scenes within an act
        r.on "scenes", Integer do |scene_id|
          @scene = Scene.where(act_id: @act.id, id: scene_id).first or r.halt(404, "Scene not found")

          # GET /plays/:play_id/acts/:act_id/scenes/:scene_id - Show scene with speeches
          r.is do
            r.get do
              @speeches = @scene.speeches_dataset.order(:speech_order).all
              view("plays/show_scene")
            end
          end

          # Routes for speeches within a scene
          r.on "speeches", Integer do |speech_id|
            @speech = Speech.where(scene_id: @scene.id, id: speech_id).first or r.halt(404, "Speech not found")

            # GET /plays/:play_id/acts/:act_id/scenes/:scene_id/speeches/:speech_id - Show speech with lines
            r.is do
              r.get do
                @lines = @speech.speech_lines_dataset.order(:start_line_number).all
                @interpretations = Interpretation.where(speech_line_id: @lines.map(&:id)).eager(:user).all.group_by(&:speech_line_id)
                view("plays/show_speech")
              end
            end
          end
        end
      end
    end
  end
end
