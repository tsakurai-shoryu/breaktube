require File.expand_path '../test_helper.rb', __dir__

class ApiTest < TestHelper
  def test_post_index
    post '/', text: "dummy"
    assert last_response.ok?
    assert_match /不正な値です。/, last_response.body
  end

  def test_post_index_help
    post '/', text: "help"
    assert last_response.ok?
    assert_match /breaktubeとは？/, last_response.body
  end
end