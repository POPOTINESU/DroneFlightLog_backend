class ProblemField < ApplicationRecord
  # FK
  # ユーザーとフライトログの中間テーブル
  # 飛行記録に紐づく問題フィールド
  belongs_to :user
  belongs_to :flight_log
end
