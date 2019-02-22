json.extract! api_product, :id, :name, :content, :price, :created_at, :updated_at
json.url api_product_url(api_product, format: :json)
