Spree::Payment.class_eval do
  self.state_machine.before_transition to: :completed, do: :avalara_finalize
  self.state_machine.before_transition to: :processing, do: :avalara_update
  self.state_machine.after_transition to: :void, do: :cancel_avalara

  def avalara_tax_enabled?
    Spree::Config.avatax_tax_calculation
  end

  def cancel_avalara
    order.avalara_transaction.cancel_order unless order.avalara_transaction.nil?
  end

  def avalara_update
    return if self.source.class.name == "Spree::StoreCredit"
    # without reload order was charged without tax amount
    order.reload

    if self.amount != order.order_total_after_store_credit
      self.update_attributes(amount: order.order_total_after_store_credit)
    end
  end

  def avalara_finalize
    return unless avalara_tax_enabled?
    return if self.source.class.name == "Spree::StoreCredit"

    if self.amount != order.order_total_after_store_credit
      self.update_attributes(amount: order.order_total_after_store_credit)
    end

    order.avalara_capture_finalize
  end
end
