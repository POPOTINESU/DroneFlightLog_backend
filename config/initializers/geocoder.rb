Geocoder.configure(
  # Geocoding options
  lookup: :google,
  api_key: Rails.application.credentials.googleMaps_API_KEY,
  use_https: true,
  language: :ja,
  units: :km,
  timeout: 15,
  )
