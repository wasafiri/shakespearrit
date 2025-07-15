require_relative '../test_helper'

describe 'Feature: Video Pipeline (TODO Phase 1)' do
  before do
    @user = create_user
    @play = create_play
    @speech_line = create_speech_line(@play)
  end

  let(:video_service_mock) do
    mock = Minitest::Mock.new
    mock.expect(:create_direct_upload, { 'url' => 'https://mock.upload.url/123', 'id' => 'mock_asset_123' })
    mock
  end

  it 'API provides a signed URL for direct video uploads' do
    # This test assumes a new service class, e.g., VideoService, that abstracts the video provider.
    # We stub this service to avoid making real external API calls.
    VideoService.stub :new, video_service_mock do
      login_as(@user) # Assumes a login helper or direct session manipulation
      post '/api/v1/uploads/new', { speech_line_id: @speech_line.id }
    end

    assert_equal 200, last_response.status
    assert_equal 'https://mock.upload.url/123', json_response['upload_url']
    assert_equal 'mock_asset_123', json_response['asset_id']
    video_service_mock.verify
  end

  it 'API creates an interpretation record with "processing" status after upload is initiated' do
    login_as(@user)
    
    # This endpoint would be hit by the client *after* it gets the signed URL
    # to let our backend know a file is being uploaded.
    assert_difference 'Interpretation.count', 1 do
      post '/api/v1/interpretations', {
        speech_line_id: @speech_line.id,
        asset_id: 'new_asset_456'
      }
    end

    assert_equal 201, last_response.status
    new_interpretation = Interpretation.last
    assert_equal @user.id, new_interpretation.user_id
    assert_equal 'processing', new_interpretation.status
    assert_equal 'new_asset_456', new_interpretation.asset_id
    assert_nil new_interpretation.playback_id
  end

  it 'Webhook updates interpretation status to "ready" upon receiving notification' do
    interpretation = create_interpretation(@user, @speech_line, status: 'processing', asset_id: 'asset_abc')

    webhook_payload = {
      type: 'video.asset.ready',
      data: {
        id: 'asset_abc',
        playback_ids: [{ id: 'playback_xyz' }]
      }
    }.to_json

    post '/api/v1/webhooks/video', webhook_payload, { 'CONTENT_TYPE' => 'application/json' }

    assert_equal 204, last_response.status # 204 No Content is a good response for a webhook
    interpretation.reload
    assert_equal 'ready', interpretation.status
    assert_equal 'playback_xyz', interpretation.playback_id
  end
end
