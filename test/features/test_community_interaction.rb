require_relative '../test_helper'

describe 'Feature: Community Interaction (TODO Phase 2)' do
  before do
    @user1 = create_user(display_name: 'User One')
    @user2 = create_user(display_name: 'User Two')
    @play = create_play
    @speech_line = create_speech_line(@play)
    @interpretation = create_interpretation(@user1, @speech_line)
  end

  describe 'Ratings' do
    it 'allows a user to submit a 5-star rating with a tag' do
      login_as(@user2)
      assert_difference 'Rating.count', 1 do
        post "/api/v1/interpretations/#{@interpretation.id}/ratings", {
          stars: 5,
          tag: 'clarity'
        }
      end

      assert_equal 201, last_response.status
      new_rating = Rating.last
      assert_equal @user2.id, new_rating.user_id
      assert_equal 5, new_rating.stars
      assert_equal 'clarity', new_rating.tag
    end

    it 'does not allow a user to rate their own interpretation' do
      login_as(@user1)
      assert_no_difference 'Rating.count' do
        post "/api/v1/interpretations/#{@interpretation.id}/ratings", { stars: 4 }
      end
      assert_equal 403, last_response.status # Forbidden
    end
  end

  describe 'Comments' do
    it 'allows a user to post a text comment on an interpretation' do
      login_as(@user2)
      assert_difference 'Comment.count', 1 do
        post "/api/v1/interpretations/#{@interpretation.id}/comments", {
          body: 'A wonderful take on the line!'
        }
      end
      assert_equal 201, last_response.status
      assert_equal 'A wonderful take on the line!', Comment.last.body
    end

    it 'allows a user to reply to another comment (threading)' do
      login_as(@user2)
      parent_comment = Comment.create(user_id: @user1.id, interpretation_id: @interpretation.id, body: 'Parent')
      
      assert_difference 'Comment.count', 1 do
        post "/api/v1/comments/#{parent_comment.id}/replies", {
          body: 'This is a reply.'
        }
      end
      assert_equal 201, last_response.status
      reply = Comment.last
      assert_equal parent_comment.id, reply.parent_comment_id
      assert_equal 'This is a reply.', reply.body
    end
  end

  describe 'Forking' do
    it 'allows a user to fork an interpretation' do
      login_as(@user2)
      assert_difference 'Interpretation.count', 1 do
        post "/api/v1/interpretations/#{@interpretation.id}/fork"
      end

      assert_equal 201, last_response.status
      forked_interpretation = Interpretation.last
      
      assert_equal @user2.id, forked_interpretation.user_id
      assert_equal @interpretation.speech_line_id, forked_interpretation.speech_line_id
      assert_equal @interpretation.id, forked_interpretation.source_interpretation_id # Crucial check
      assert_equal 'processing', forked_interpretation.status # A forked clip is a new video
    end

    it 'does not allow a user to fork their own interpretation' do
      login_as(@user1)
      assert_no_difference 'Interpretation.count' do
        post "/api/v1/interpretations/#{@interpretation.id}/fork"
      end
      assert_equal 403, last_response.status
    end
  end
end
