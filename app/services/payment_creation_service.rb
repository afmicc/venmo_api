class PaymentCreationService
  attr_accessor :user, :params

  def initialize(user)
    @user = user
  end

  def create!(params)
    @params = params

    validate!

    Payment.create!(
      sender: user,
      receiver: friend,
      amount: params[:amount],
      description: params[:description] || ''
    )
  end

  private

  def validate!
    raise Payments::NoFriendsError unless user.friends.include?(friend)
  end

  def friend
    @friend ||= User.find(params[:friend_id])
  end
end
