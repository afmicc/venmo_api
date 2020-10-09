module Api
  module V1
    class UsersController < ApplicationController
      include Pagy::Backend

      def show; end

      def create
        @current_user = User.create!(user_params)
        render :show
      end

      def feed
        query = Event.where(user_id: current_user.contacts_for_feed).order(created_at: :desc)
        pagy, @events = pagy(query, page: page)
        @metadata = pagy_metadata(pagy)
      end

      private

      def user_params
        params.require(:user).permit(:email, :name)
      end

      def page
        params[:page] || 1
      end
    end
  end
end
