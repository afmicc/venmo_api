module Payments
  class NoFriendsError < VenmoApiError
    def initialize(msg = I18n.t('errors.payment.no_friends'))
      super
    end
  end
end
