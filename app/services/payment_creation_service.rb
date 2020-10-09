class PaymentCreationService
  attr_accessor :user, :params

  def initialize(user)
    @user = user
  end

  def create!(params)
    @params = params

    validate!

    ActiveRecord::Base.transaction do
      payment = create_payment
      EventRegisterService.new.by_payment!(payment)
    end
  end

  private

  def validate!
    raise Payments::NoFriendsError unless user.friends.include?(friend)
  end

  def friend
    @friend ||= User.find(params[:friend_id])
  end

  def create_payment
    Payment.create!(
      sender: user,
      receiver: friend,
      amount: params[:amount],
      description: params[:description] || ''
    )
  end
end
