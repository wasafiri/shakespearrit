require 'yt'

class ShakespeareApp
  route("api", "v1", "uploads") do |r|
    r.post do
      require_login!

      begin
        # 1. Retrieve parameters
        video_file = r.params['video_file']
        speech_line_id = r.typecast_params.pos_int!('speech_line_id')
        description = r.typecast_params.str('description', '')

        # --- Validations ---
        r.halt(400, { error: 'Video file is required.' }.to_json) unless video_file && video_file[:tempfile]

        # 2. Authenticate with YouTube
        r.halt(403, { error: 'YouTube account not linked.' }.to_json) unless current_user.youtube_refresh_token

        account = Yt::Account.new(refresh_token: current_user.youtube_refresh_token)

        # 3. Upload the video to YouTube
        speech_line = SpeechLine[speech_line_id]
        r.halt(404, { error: 'Speech line not found.' }.to_json) unless speech_line
        
        play_title = speech_line.speech.scene.act.play.title
        video_title = "ASL Interpretation: #{play_title}, Act #{speech_line.speech.scene.act.act_number}, Scene #{speech_line.speech.scene.scene_number}"
        video_description = "An ASL interpretation of a line from Shakespeare's #{play_title}.\n\nOriginal line: \"#{speech_line.text}\"\n\nContributed by: #{current_user.email}"

        uploaded_video = account.upload_video(
          video_file[:tempfile].path,
          title: video_title,
          description: video_description,
          privacy_status: 'unlisted'
        )

        # 4. Create a new Interpretation record
        interpretation = Interpretation.create(
          user_id: current_user.id,
          speech_line_id: speech_line_id,
          youtube_video_id: uploaded_video.id,
          description: description,
          status: 'approved'
        )

        # 5. Return success response
        {
          status: 'success',
          message: 'Video uploaded and interpretation created.',
          interpretation_id: interpretation.id,
          youtube_video_id: uploaded_video.id
        }

      rescue Yt::Error => e
        response.status = 500
        { error: "Failed to upload video to YouTube: #{e.message}" }
      rescue Sequel::Error => e
        response.status = 500
        { error: 'Failed to save interpretation to the database.' }
      rescue => e
        response.status = 500
        { error: 'An unexpected error occurred.' }
      end
    end
  end
end
