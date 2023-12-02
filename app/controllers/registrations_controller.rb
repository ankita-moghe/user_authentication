class RegistrationsController < ApplicationController

	def create
    @user = User.new(create_params)
    if @user.save
    	session = @user.sessions.create(secret_id: @user.generate_session_token)
    	UserMailer.welcome_email(@user).deliver_now
      render json: { user: @user, session_token: session.secret_id }, status: :created
    else
      render json: { errors: @user.errors } , status: :unprocessable_entity
    end
	end

	private
	  def create_params
      params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
    end
end
