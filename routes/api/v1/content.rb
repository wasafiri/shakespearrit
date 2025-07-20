require 'json'

class ShakespeareApp
  route("api", "v1", "content") do |r|
    response['Content-Type'] = 'application/json'

    # GET /api/v1/content/plays
    r.on "plays" do
      r.is do
        r.get do
          rescue_api_errors do
            plays = Play.order(:title).select(:id, :title).all
            r.halt(200, plays.to_json)
          end
        end
      end

      # GET /api/v1/content/plays/:id/acts
      r.on Integer, "acts" do |play_id|
        r.get do
          rescue_api_errors do
            acts = Act.where(play_id: play_id).order(:act_number).select(:id, :act_number).all
            r.halt(200, acts.to_json)
          end
        end
      end
    end

    # GET /api/v1/content/acts/:id/scenes
    r.on "acts", Integer, "scenes" do |act_id|
      r.get do
        rescue_api_errors do
          scenes = Scene.where(act_id: act_id).order(:scene_number).select(:id, :scene_number).all
          r.halt(200, scenes.to_json)
        end
      end
    end

    # GET /api/v1/content/scenes/:id/speeches
    r.on "scenes", Integer, "speeches" do |scene_id|
      r.get do
        rescue_api_errors do
          speeches = Speech.where(scene_id: scene_id).order(:order_in_scene).select(:id, :character).all
          r.halt(200, speeches.to_json)
        end
      end
    end
    
    # GET /api/v1/content/speeches/:id
    r.on "speeches", Integer do |speech_id|
      r.get do
        rescue_api_errors do
          speech = Speech[speech_id]
          r.halt(404, { error: "Speech not found." }.to_json) unless speech

          lines = speech.speech_lines_dataset.order(:start_line_number).all
          interpretations = Interpretation.where(speech_line_id: lines.map(&:id)).eager(:user).all.group_by(&:speech_line_id)

          result = {
            id: speech.id,
            character: speech.character,
            lines: lines.map do |line|
              {
                id: line.id,
                text: line.text,
                interpretations: interpretations.fetch(line.id, []).map do |interp|
                  {
                    id: interp.id,
                    youtube_video_id: interp.youtube_video_id,
                    description: interp.description,
                    user: { id: interp.user.id, email: interp.user.email }
                  }
                end
              }
            end
          }
          r.halt(200, result.to_json)
        end
      end
    end
  end
end
