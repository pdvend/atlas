module Atlas
  module Service
    SystemContext = RequestContext.new(
      time: DateTime.now,
      component: 'SystemContext',
      caller: 'System',
      transaction_id: SecureRandom.uuid,
      account_id: nil,
      authentication_type: :system
    )
  end
end
