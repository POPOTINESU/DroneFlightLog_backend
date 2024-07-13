Mailjet.configure do |config|
  config.api_key = Rails.application.credentials.dig(:mailjet, :api_key)
  config.secret_key = Rails.application.credentials.dig(:mailjet, :secret_key)
  config.default_from = 'developershige@gmail.com'
end
