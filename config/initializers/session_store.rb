# config/initializers/session_store.rb

# config/initializers/session_store.rb

if Rails.env.production?
  Rails.application.config.session_store :cookie_store, key: '_your_app_session', domain: '.drone-flight-log.com', secure: true, same_site: :lax
elsif Rails.env.development?
  Rails.application.config.session_store :cookie_store, key: '_your_app_session', domain: '.drone-flight-log.com', same_site: :lax
end
