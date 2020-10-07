module Api
  module V1
    class UsersController < ApplicationController
      def show; end

      def create
        @current_user = User.create!(user_params)
        render :show
      end

      private

      def user_params
        params.require(:user).permit(:email, :name)
      end
    end
  end
end
