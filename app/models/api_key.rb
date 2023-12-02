class ApiKey < ApplicationRecord
  validates :key, presence: true, uniqueness: true
end
