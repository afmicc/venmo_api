module Api
  module V1
    module Users
      class PaymentsController < ApplicationController
        def create
          PaymentCreationService.new(current_user).create!(payment_params)
          head :no_content
        end

        private

        def payment_params
          params.require(:payment).permit(:friend_id, :amount, :description)
        end
      end
    end
  end
end
