class Photo < ApplicationRecord
    include ImageUploader[:image]
end
