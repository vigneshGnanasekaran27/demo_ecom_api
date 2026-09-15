# Full order detail for the admin/dispatch/delivery consoles — everything
# OrderSerializer already has (items, shipping, totals, status history)
# plus what only internal staff should see: who the customer actually is
# (account or guest) and the real payment record(s), not just the order's
# summary payment_status.
class AdminOrderDetailSerializer
  def initialize(order)
    @order = order
  end

  def as_json(*)
    OrderSerializer.new(order).as_json.merge(
      customer: customer_info,
      payments: order.payments.order(:created_at).map { |payment| payment_entry(payment) }
    )
  end

  private

  attr_reader :order

  def customer_info
    if order.user
      { type: "account", id: order.user.id, name: order.user.full_name, email: order.user.email, phone: order.user.phone }
    else
      { type: "guest", id: nil, name: order.shipping_name, email: nil, phone: order.shipping_phone }
    end
  end

  def payment_entry(payment)
    {
      id: payment.id,
      status: payment.status,
      amount_cents: payment.amount_cents,
      razorpay_order_id: payment.razorpay_order_id,
      razorpay_payment_id: payment.razorpay_payment_id,
      created_at: payment.created_at
    }
  end
end
