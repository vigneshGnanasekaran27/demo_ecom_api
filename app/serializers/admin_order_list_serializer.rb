# Lean listing for the admin console's order table (ADMIN-01) — status,
# total, customer, date. Full detail (items, shipping, status history) is
# available via OrderSerializer if a future admin detail view needs it.
class AdminOrderListSerializer
  def initialize(order)
    @order = order
  end

  def as_json(*)
    {
      id: order.id,
      order_number: order.order_number,
      order_status: order.order_status,
      payment_status: order.payment_status,
      total_cents: order.total_cents,
      customer_name: order.user&.full_name || order.shipping_name,
      item_count: order.order_items.size,
      created_at: order.created_at
    }
  end

  private

  attr_reader :order
end
