# Create a user
User.create(first_name: 'User', last_name: 'Test', email: 'example@mail.com', password: 'password')

# Create a group
Group.create(name: 'Group Test')

# Create a group_user
# idがuuidのため、User.find_by(id: 1)では取得できない
user = User.find_by(email: 'example@mail.com')
group = Group.find_by(name: 'Group Test')

GroupUser.create(user_id: user.id, group_id: group.id)
