json.extract! movie, :id, :title, :content, :created_at, :updated_at
json.url movie_url(movie, format: :json)
