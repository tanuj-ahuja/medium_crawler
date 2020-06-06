class Article < ApplicationRecord
	has_many :tags, dependent: :destroy
	has_many :responses, dependent: :destroy
end
