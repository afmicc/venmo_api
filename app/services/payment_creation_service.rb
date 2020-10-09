class PaymentCreationService
  attr_reader :user, :event_register
  attr_accessor :params

  def initialize(user)
    @user = user
    @event_register = EventRegisterService.new
  end

  def create!(params)
    @params = params

    validate!
    ActiveRecord::Base.transaction do
      payment = create_payment
      impact_balances
      event_register.by_payment!(payment)
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
      amount: amount,
      description: params[:description] || ''
    )
  end

  def amount
    @amount ||= params[:amount].to_f
  end

  def impact_balances
    sender_account_manager = AccountManagerService.new(user)
    receiver_account_manager = AccountManagerService.new(friend)

    sender_account_manager.decrease_account!(amount)
    receiver_account_manager.increase_account!(amount)
  end
end
