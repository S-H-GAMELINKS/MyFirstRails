json.extract! product, :id, :title, :content, :price, :created_at, :updated_at
json.url product_url(product, format: :json)
