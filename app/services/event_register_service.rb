class EventRegisterService
  def by_payment!(payment)
    Event.create!(
      user: payment.sender,
      content: I18n.t(
        'model.event.by_payment',
        sender: payment.sender_name,
        receiver: payment.receiver_name,
        date: I18n.l(payment.created_at, format: :short),
        description: payment.description
      )
    )
  end
end
