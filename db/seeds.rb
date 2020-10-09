aleen = User.find_or_create_by!(name: 'Aleen', email: 'aleen@example.com')
gilbert = User.find_or_create_by!(name: 'Gilbert', email: 'gilbert@example.com')
jhon = User.find_or_create_by!(name: 'Jhon', email: 'jhon@example.com')
kerry = User.find_or_create_by!(name: 'Kerry', email: 'kerry@example.com')
livia = User.find_or_create_by!(name: 'Livia', email: 'livia@example.com')
mellisa = User.find_or_create_by!(name: 'Mellisa', email: 'mellisa@example.com')
User.find_or_create_by!(name: 'Ozzie', email: 'ozzie@example.com')
richard = User.find_or_create_by!(name: 'Richard', email: 'richard@example.com')
suzann = User.find_or_create_by!(name: 'Suzann', email: 'suzann@example.com')
willy = User.find_or_create_by!(name: 'Willy', email: 'willy@example.com')

Friendship.find_or_create_by!(user: aleen, friend: livia)
Friendship.find_or_create_by!(user: aleen, friend: kerry)
Friendship.find_or_create_by!(user: livia, friend: suzann)
Friendship.find_or_create_by!(user: livia, friend: gilbert)
Friendship.find_or_create_by!(user: kerry, friend: suzann)
Friendship.find_or_create_by!(user: kerry, friend: suzann)
Friendship.find_or_create_by!(user: gilbert, friend: jhon)
Friendship.find_or_create_by!(user: jhon, friend: mellisa)
Friendship.find_or_create_by!(user: willy, friend: richard)
