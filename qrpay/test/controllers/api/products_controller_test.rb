require 'test_helper'

class Api::ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @api_product = api_products(:one)
  end

  test "should get index" do
    get api_products_url, as: :json
    assert_response :success
  end

  test "should create api_product" do
    assert_difference('Api::Product.count') do
      post api_products_url, params: { api_product: { content: @api_product.content, name: @api_product.name, price: @api_product.price } }, as: :json
    end

    assert_response 201
  end

  test "should show api_product" do
    get api_product_url(@api_product), as: :json
    assert_response :success
  end

  test "should update api_product" do
    patch api_product_url(@api_product), params: { api_product: { content: @api_product.content, name: @api_product.name, price: @api_product.price } }, as: :json
    assert_response 200
  end

  test "should destroy api_product" do
    assert_difference('Api::Product.count', -1) do
      delete api_product_url(@api_product), as: :json
    end

    assert_response 204
  end
end
