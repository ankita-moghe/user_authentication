class UserMailer < ApplicationMailer
  default from: 'your_email@example.com'

  def welcome_email(user)
    @user = user
    mail(to: @user.email, subject: 'Welcome to My App!')
  end

  def send_token(user, token)
    @user = user
    @token = token
    mail(to: @user.email, subject: 'Your authentication code')
  end
end
