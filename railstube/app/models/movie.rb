class Movie < ApplicationRecord
    has_one_attached :movie
    has_many :comments
end
