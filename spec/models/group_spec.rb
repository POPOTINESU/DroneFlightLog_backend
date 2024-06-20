require 'rails_helper'

RSpec.describe Group, type: :model do
  it 'グループ名があれば参照できること' do
    group = FactoryBot.build(:group)
    expect(group).to be_valid
  end

  it 'グループ名がなければ無効な状態であること' do
    group = FactoryBot.build(:group, name: nil)
    group.valid?
    expect(group.errors[:name]).to include('グループ名を入力してください')
  end
end
