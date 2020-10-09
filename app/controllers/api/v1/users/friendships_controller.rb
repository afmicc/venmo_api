module Api
  module V1
    module Users
      class FriendshipsController < ApplicationController
        def create
          current_user.outgoing_friends << friend
          head :no_content
        end

        private

        def friend
          User.find(params[:friend_id])
        end
      end
    end
  end
end
