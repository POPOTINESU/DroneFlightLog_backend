# config/initializers/session_store.rb

if Rails.env.production?
  Rails.application.config.session_store :cookie_store, key: '_your_app_session', secure: true, same_site: :none
elsif Rails.env.development?
  Rails.application.config.session_store :cookie_store, key: '_your_app_session', same_site: :lax
end
