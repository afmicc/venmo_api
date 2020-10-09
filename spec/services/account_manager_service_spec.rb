require 'rails_helper'

RSpec.describe AccountManagerService do
  let!(:user) { create(:user) }

  describe '#increase_account!' do
    subject { described_class.new(user).increase_account!(amount) }

    context 'when the amount is positive' do
      let(:amount) { Faker::Number.decimal(l_digits: 2) }

      it 'increases the user account balane' do
        expect { subject }.to change { user.account.reload.balance }.by(amount)
      end
    end

    context 'when the amount is 0' do
      let(:amount) { 0 }

      it 'does not increases the user account balane' do
        expect { subject }.not_to change { user.account.reload.balance }
      end
    end

    context 'when the amount is negative' do
      let(:amount) { -Faker::Number.decimal(l_digits: 2) }

      it 'does not increases the user account balane' do
        expect { subject }.not_to change { user.account.reload.balance }
      end
    end
  end

  describe '#decrease_account!' do
    subject { described_class.new(user).decrease_account!(amount) }

    context 'when the amount is positive' do
      let(:amount) { Faker::Number.decimal(l_digits: 2) }

      context 'when the amount is less than the user account balance' do
        let(:initial_balance) { amount * 2 }

        before do
          user.account.update!(balance: initial_balance)
        end

        it 'decreases the user account balane' do
          expect { subject }.to change { user.account.reload.balance }.by(-amount)
        end

        it 'does not call to an external money service' do
          expect_any_instance_of(MoneyTransferService).not_to receive(:transfer)
          subject
        end
      end

      context 'when the amount is equals to the user account balance' do
        let(:initial_balance) { amount }

        before do
          user.account.update!(balance: initial_balance)
        end

        it 'decreases the user account balane til 0' do
          expect { subject }.to change { user.account.reload.balance }.to(0)
        end

        it 'does not call to an external money service' do
          expect_any_instance_of(MoneyTransferService).not_to receive(:transfer)
          subject
        end
      end

      context 'when the amount is greater than the user account balance' do
        let(:initial_balance) { Faker::Number.between(from: 1, to: (amount - 1)) }

        before do
          user.account.update!(balance: initial_balance)
        end

        it 'decreases the user account balane til 0' do
          expect { subject }.to change { user.account.reload.balance }.to(0)
        end

        it 'calls to an external money service to get the remaining money' do
          diff = amount - initial_balance
          expect_any_instance_of(MoneyTransferService).to receive(:transfer).with(diff)
          subject
        end
      end
    end

    context 'when the amount is 0' do
      let(:amount) { 0 }

      it 'does not increases the user account balane' do
        expect { subject }.not_to change { user.account.reload.balance }
      end
    end

    context 'when the amount is negative' do
      let(:amount) { -Faker::Number.decimal(l_digits: 2) }

      it 'does not increases the user account balane' do
        expect { subject }.not_to change { user.account.reload.balance }
      end
    end
  end
end
