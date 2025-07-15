require_relative '../test_helper'

describe 'Feature: SPA Content API (TODO Phase 1)' do
  before do
    @user = create_user
    @play = create_play
    @speech_line = create_speech_line(@play)
    @interpretation1 = create_interpretation(@user, @speech_line)
    @interpretation2 = create_interpretation(@user, @speech_line)
  end

  it 'API returns a list of all plays for the navigator' do
    get '/api/v1/plays'

    assert_equal 200, last_response.status
    assert_equal 1, json_response.count
    assert_equal 'Twelfth Night', json_response.first['title']
  end

  it 'API returns the acts for a given play' do
    get "/api/v1/plays/#{@play.id}/acts"

    assert_equal 200, last_response.status
    assert_equal 1, json_response.count
    assert_equal 1, json_response.first['act_number']
  end

  it 'API returns a speech and its interpretations' do
    speech_id = @speech_line.speech.id
    get "/api/v1/speeches/#{speech_id}"

    assert_equal 200, last_response.status
    
    response = json_response
    assert_equal 'ORSINO', response['speaker']
    assert_equal 1, response['lines'].count
    assert_equal 'If music be the food of love, play on.', response['lines'].first['text']
    
    assert_equal 2, response['lines'].first['interpretations'].count
    playback_ids = response['lines'].first['interpretations'].map { |i| i['playback_id'] }
    assert_includes playback_ids, @interpretation1.playback_id
    assert_includes playback_ids, @interpretation2.playback_id
  end

  it 'API returns a 404 for a non-existent speech' do
    get '/api/v1/speeches/99999'
    assert_equal 404, last_response.status
  end
end
