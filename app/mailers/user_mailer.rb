class UserMailer < ApplicationMailer
  include Rails.application.routes.url_helpers

  def reset_password_email(user)
    @user = user
    @url = generate_password_reset_url(@user.reset_password_token)
    mail(to: @user.email, subject: 'Password Reset Instructions')
  end

  private

  def generate_password_reset_url(token)
    host = Rails.application.config.action_mailer.default_url_options[:host]
    port = Rails.application.config.action_mailer.default_url_options[:port]
    protocol = Rails.application.config.action_mailer.default_url_options[:protocol] || 'http'

    # 開発環境ではポート番号を含める
    if Rails.env.development?
      "#{protocol}://#{host}:#{port}/password_reset/#{token}"
    else
      "#{protocol}://#{host}/password_reset/#{token}"
    end
  end
end
