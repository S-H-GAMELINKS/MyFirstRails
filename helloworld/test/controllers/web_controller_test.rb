require 'test_helper'

class WebControllerTest < ActionDispatch::IntegrationTest
  test "should get hello" do
    get web_hello_url
    assert_response :success
  end

end
