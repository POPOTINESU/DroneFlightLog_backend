Geocoder.configure(
  lookup: :nominatim,
  http_headers: { "User-Agent" => "my_app" },  # Nominatimの使用にはUser-Agentが必要
  timeout: 5,  # リクエストのタイムアウト時間
  units: :km   # 距離の単位
)
