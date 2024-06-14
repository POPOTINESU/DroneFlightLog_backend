FactoryBot.define do
  factory :user do
    first_name { 'User' }
    last_name { 'Test' }
    email { 'example@mail.com' }
    password { 'password' }
  end
end
