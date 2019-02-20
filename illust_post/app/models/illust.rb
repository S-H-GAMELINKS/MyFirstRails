class Illust < ApplicationRecord
    has_many_attached :illusts
    has_many :comments
end
