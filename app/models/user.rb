class User < ApplicationRecord
	has_secure_password

	has_many :sessions
  
  validates :first_name, presence: true, length: { maximum: 255 }
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }

  def generate_session_token
  	SecureRandom.urlsafe_base64 12
  end

  def update_password(new_password)
  	update!(password: new_password)
  end

  def generate_token
  	token = SecureRandom.hex(3)
  	self.otp_secret_key = Digest::SHA256.hexdigest(token)
  	self.otp_generated_at = Time.now
  	self.save
  	return token
  end

  def validate_token(token)
  	self.otp_secret_key == Digest::SHA256.hexdigest(token)
  end
end
