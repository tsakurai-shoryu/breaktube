require File.expand_path '../test_helper.rb', __dir__

class ToolsTest < TestHelper
  def test_message_response
    message = message_response("test",attachments: {})
    assert_equal message, '{"content_type":"application/json","response_type":"in_channel","replace_original":false,"text":"test","attachments":{}}'
  end
end