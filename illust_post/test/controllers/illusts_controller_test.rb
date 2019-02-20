require 'test_helper'

class IllustsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @illust = illusts(:one)
  end

  test "should get index" do
    get illusts_url
    assert_response :success
  end

  test "should get new" do
    get new_illust_url
    assert_response :success
  end

  test "should create illust" do
    assert_difference('Illust.count') do
      post illusts_url, params: { illust: { content: @illust.content, title: @illust.title } }
    end

    assert_redirected_to illust_url(Illust.last)
  end

  test "should show illust" do
    get illust_url(@illust)
    assert_response :success
  end

  test "should get edit" do
    get edit_illust_url(@illust)
    assert_response :success
  end

  test "should update illust" do
    patch illust_url(@illust), params: { illust: { content: @illust.content, title: @illust.title } }
    assert_redirected_to illust_url(@illust)
  end

  test "should destroy illust" do
    assert_difference('Illust.count', -1) do
      delete illust_url(@illust)
    end

    assert_redirected_to illusts_url
  end
end
