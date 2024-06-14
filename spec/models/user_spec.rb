require 'rails_helper'

RSpec.describe User, type: :model do
  it '性、名、メール、パスワードがあれば有効な状態であること' do
    user = FactoryBot.build(:user)
    expect(user).to be_valid
  end

  it '名がなければ無効な状態であること' do
    user = FactoryBot.build(:user, first_name: nil)
    user.valid?
    expect(user.errors[:first_name]).to include('名を入力してください')
  end
  it '性がなければ無効な状態であること' do
    user = FactoryBot.build(:user, last_name: nil)
    user.valid?
    expect(user.errors[:last_name]).to include('姓を入力してください')
  end

  it 'メールアドレスがなければ無効な状態であること' do
    user = FactoryBot.build(:user, email: nil)
    user.valid?
    expect(user.errors[:email]).to include('メールアドレスを入力してください')
  end

  it '重複したメールアドレスなら無効な状態であること' do
    FactoryBot.create(:user)
    user = User.new(
      first_name: 'User1',
      last_name: 'Test1',
      email: 'example@mail.com',
      password: 'password'
    )
    user.valid?
    expect(user.errors[:email]).to include('このメールアドレスは既に登録されています')
  end

  it 'ユーザーのフルネームを文字列として返すこと' do
    user = User.new(
      first_name: 'User',
      last_name: 'Test',
      email: 'example@mail.com',
      password: 'password'
    )
    expect(user.full_name).to eq 'Test User'
  end
end
