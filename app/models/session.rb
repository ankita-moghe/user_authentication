class Session < ApplicationRecord

  belongs_to :user

  validates :secret_id , presence: true
end
