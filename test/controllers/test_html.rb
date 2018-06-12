require File.expand_path '../test_helper.rb', __dir__

class HtmlTest < TestHelper
  def test_index
    get '/'
    assert last_response.ok?
    assert_match /<div id=\"player\">/, last_response.body
  end
end