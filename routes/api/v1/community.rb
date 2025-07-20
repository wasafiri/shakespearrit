require 'json'

class ShakespeareApp
  route "api", "v1", "interpretations" do |r|
    response['Content-Type'] = 'application/json'

    r.on Integer do |interpretation_id|
      @interpretation = Interpretation[interpretation_id]
      r.halt(404, { error: "Interpretation not found." }.to_json) unless @interpretation

      # POST /api/v1/interpretations/:id/ratings
      r.on "ratings" do
        r.post do
          require_login!
          
          stars = r.typecast_params.pos_int('stars')
          tag = r.typecast_params.str('tag')

          r.halt(400, { error: 'Rating must be between 1 and 5 stars.'}.to_json) unless stars && (1..5).cover?(stars)

          rating = @interpretation.add_rating(user: current_user, stars: stars, tag: tag)
          if rating.valid?
            r.halt(201, { status: 'success', rating_id: rating.id }.to_json)
          else
            r.halt(422, { error: 'You have already rated this interpretation.' }.to_json)
          end
        end
      end

      # POST /api/v1/interpretations/:id/comments
      r.on "comments" do
        r.post do
          require_login!

          body = r.typecast_params.nonempty_str!('body')
          parent_id = r.typecast_params.pos_int('parent_comment_id')

          comment = @interpretation.add_comment(
            user: current_user,
            body: body,
            parent_comment_id: parent_id
          )

          if comment.valid?
            r.halt(201, { status: 'success', comment_id: comment.id }.to_json)
          else
            r.halt(422, { error: 'Could not post comment.' }.to_json)
          end
        end
      end

      # POST /api/v1/interpretations/:id/fork
      r.on "fork" do
        r.post do
          require_login!

          # A user cannot fork their own interpretation
          r.halt(403, { error: 'Cannot fork your own interpretation.' }.to_json) if current_user.id == @interpretation.user_id

          begin
            forked_interpretation = Interpretation.create(
              user_id: current_user.id,
              speech_line_id: @interpretation.speech_line_id,
              youtube_video_id: @interpretation.youtube_video_id, # Or a placeholder if video needs re-uploading
              description: "Fork of interpretation #{@interpretation.id} by #{@interpretation.user.email}",
              status: 'processing', # New forks are in processing state
              source_interpretation_id: @interpretation.id
            )

            r.halt(201, {
              status: 'success',
              message: 'Interpretation forked successfully.',
              interpretation_id: forked_interpretation.id
            }.to_json)
          rescue Sequel::Error => e
            logger.error "Database Error forking interpretation: #{e.message}"
            r.halt(500, { error: 'Failed to fork interpretation.' }.to_json)
          rescue => e
            logger.error "Unexpected error during forking: #{e.class} - #{e.message}"
            r.halt(500, { error: 'An unexpected error occurred during forking.' }.to_json)
          end
        end
      end
    end
  end
end