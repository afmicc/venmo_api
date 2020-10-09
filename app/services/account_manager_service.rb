class AccountManagerService
  attr_reader :user, :account, :money_transfer_service

  def initialize(user)
    @user = user
    @account = user.account
    mock_external_service = Object.new
    @money_transfer_service = MoneyTransferService.new(mock_external_service, self)
  end

  def increase_account!(amount)
    return unless amount.positive?

    account.balance += amount
    account.save!
  end

  def decrease_account!(amount)
    return unless amount.positive?

    diff = account.balance - amount

    if diff.negative?
      money_transfer_service.transfer(diff.abs)
      account.balance = 0
    else
      account.balance -= amount
    end

    account.save!
  end
end
