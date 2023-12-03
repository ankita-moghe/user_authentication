class UsersController < ApplicationController
  before_action :find_user, only: [:login, :verify_token_for_login]
  before_action :find_user_by_session, only: [:log_out, :update_password, :update,
                    :verify_token, :generate_token]

  def login
    if @user.authenticate(params[:user][:password])
      if @user.two_factor_enabled
        token = @user.generate_token
        UserMailer.send_token(@user, token).deliver_now
        render json: { message: 'Authentication token sent to your registered email' }, status: :ok
      else
        session = @user.sessions.create(secret_id: @user.generate_session_token)
        render json: { user: @user, session_token: session.secret_id }, status: :ok
      end
    else
      render json: { error: 'Invalid email or password' }, status: :unprocessable_entity
    end

  end

  def log_out
    @session.destroy
    render json: { message: 'User logged out successfully' }, status: :ok
  end

  def update_password
    if @user.authenticate(params[:user][:password])
      if @user.update_password(params[:user][:new_password])
        @session.destroy
        render json: { message: 'Password updated successfully, please login with new password' }, status: :ok
      else
        render json: { error: @user.errors.full_messages.join(', ') }, status: :unprocessable_entity
      end
    else
      render json: { error: 'Invalid current password' }, status: :unprocessable_entity
    end
  end

  def update
    if update_params[:two_factor_enabled]
      token = @user.generate_token
      UserMailer.send_token(@user, token).deliver_now
      render json: { message: 'Authentication token sent to your registered email' }, status: :ok
    else
      if @user.update(update_params)
        render json: { message: 'User details updated successfully', user: @user}, status: :ok
      else
        render json: { error: @user.errors.full_messages.join(', ') }, status: :unprocessable_entity
      end
    end
  end

  def verify_token_for_login
    if @user.validate_token(params[:token])
      session = @user.sessions.create(secret_id: @user.generate_session_token)
      render json: { user: @user, session_token: session.secret_id }, status: :ok
    else
      render json: { error: 'Invalid token' }, status: :unprocessable_entity
    end
  end

  def verify_token
    if @user.validate_token(params[:token])
      @user.update(two_factor_enabled: true)
      render json: { user: @user, session_token: session.secret_id }, status: :ok
    else
      render json: { error: 'Invalid token' }, status: :unprocessable_entity
    end
  end

  def generate_token
    token = @user.generate_token
  	UserMailer.send_token(@user, token).deliver_now
  	render json: { message: 'Authentication token sent to your registered email' }, status: :ok
  end

  private
    def find_user
      @user = User.find_by(email: params[:user][:email])
      render json: { error: 'Invalid email or password' }, status: :not_found if @user.nil?
    end

    def find_user_by_session
    	@session = Session.find_by(secret_id: params[:id])
    	render json: { error: 'Invalid session id' }, status: :not_found if @session.nil?
      @user = @session.user
    end

    def update_params
    	params.require(:user).permit(:first_name, :last_name, :two_factor_enabled)
    end
end
