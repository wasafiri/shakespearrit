require_relative '../test_helper'

describe 'Feature: Curation and Quality Control (TODO Phase 3)' do
  
  describe 'Karma and Moderation System' do
    before do
      @play = create_play
      @speech_line = create_speech_line(@play)
    end

    it 'puts submissions from low-karma users into a pending queue' do
      low_karma_user = create_user(karma: 5) # Below the threshold
      login_as(low_karma_user)

      assert_difference 'Interpretation.count', 1 do
        post '/api/v1/interpretations', {
          speech_line_id: @speech_line.id,
          asset_id: 'asset_from_low_karma_user'
        }
      end
      
      assert_equal 201, last_response.status
      new_interpretation = Interpretation.last
      assert_equal 'pending', new_interpretation.status
    end

    it 'automatically approves submissions from high-karma users' do
      high_karma_user = create_user(karma: 50) # Above the threshold
      login_as(high_karma_user)

      assert_difference 'Interpretation.count', 1 do
        post '/api/v1/interpretations', {
          speech_line_id: @speech_line.id,
          asset_id: 'asset_from_high_karma_user'
        }
      end
      
      assert_equal 201, last_response.status
      new_interpretation = Interpretation.last
      # The status should be 'processing' because it's a new video, not 'approved' yet.
      # The approval is for it to be visible once processed, which is the default.
      assert_equal 'processing', new_interpretation.status
    end

    it 'allows an admin to approve a pending interpretation' do
      admin_user = create_user(is_admin: true)
      pending_interpretation = create_interpretation(create_user, @speech_line, status: 'pending')
      
      login_as(admin_user)
      post "/api/v1/admin/interpretations/#{pending_interpretation.id}/approve"

      assert_equal 200, last_response.status
      pending_interpretation.reload
      assert_equal 'approved', pending_interpretation.status
    end
  end

  describe 'Gentle Friction Onboarding' do
    it 'requires new users to complete an orientation quiz' do
      new_user = create_user(has_completed_orientation: false)
      login_as(new_user)

      # Attempt to perform an action that requires orientation
      post '/api/v1/interpretations', { speech_line_id: 1, asset_id: 'test_asset' }

      assert_equal 403, last_response.status # Forbidden
      assert_equal 'Orientation required.', json_response['error']
    end

    it 'redirects a new user to the quiz after registration' do
      # This tests the flow from the original web routes, not the API
      post '/auth/register', {
        email: 'new_quiz_user@example.com',
        password: 'password123',
        password_confirmation: 'password123',
        display_name: 'Quiz User'
      }

      assert_equal 302, last_response.status # 302 Found (Redirect)
      assert_equal '/auth/orientation-quiz', last_response.location
    end

    it 'unlocks the app after the user passes the quiz' do
      new_user = create_user(has_completed_orientation: false)
      login_as(new_user)

      # Simulate submitting correct answers to the quiz
      post '/api/v1/orientation/complete', { answers: { q1: 'a', q2: 'c', q3: 'b' } }

      assert_equal 200, last_response.status
      new_user.reload
      assert_predicate new_user, :has_completed_orientation?
    end
  end
end
