require 'test_helper'

class WebControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get web_index_url
    assert_response :success
  end

  test "should get about" do
    get web_about_url
    assert_response :success
  end

  test "should get contact" do
    get web_contact_url
    assert_response :success
  end

end
