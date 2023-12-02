class ApplicationController < ActionController::API
  before_action :validate_api_key

  private

  def validate_api_key
  	api_key = request.headers['Api-Key']
    unless ApiKey.exists?(key: api_key)
      render json: { error: 'Invalid API key' }, status: :unauthorized 
    end
  end
end
