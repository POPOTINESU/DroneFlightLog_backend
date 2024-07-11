class UserMailer < ApplicationMailer
  include Rails.application.routes.url_helpers

  default from: 'droneflightlog@example.com'

  def reset_password_email(user)
    @user = user
    @url  = edit_api_v1_password_reset_url(@user.reset_password_token, host: 'localhost:3001')
    mail(to: @user.email, subject: 'パスワードリセット')
  end
end
