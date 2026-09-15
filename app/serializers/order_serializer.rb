# Full order detail (BACKEND_RULES.md §6 envelope): items, immutable
# shipping snapshot, totals, and status — used by order creation, the
# payment verify response, and (Phase 3) customer order history/detail.
class OrderSerializer
  def initialize(order)
    @order = order
  end

  def as_json(*)
    {
      id: order.id,
      order_number: order.order_number,
      order_status: order.order_status,
      payment_status: order.payment_status,
      items: order.order_items.map { |item| OrderItemSerializer.new(item).as_json },
      subtotal_cents: order.subtotal_cents,
      discount_cents: order.discount_cents,
      delivery_charge_cents: order.delivery_charge_cents,
      total_cents: order.total_cents,
      shipping: {
        name: order.shipping_name,
        phone: order.shipping_phone,
        line1: order.shipping_line1,
        line2: order.shipping_line2,
        city: order.shipping_city,
        state: order.shipping_state,
        postal_code: order.shipping_postal_code,
        landmark: order.shipping_landmark,
        country: order.shipping_country
      },
      razorpay_order_id: order.razorpay_order_id,
      placed_at: order.placed_at,
      confirmed_at: order.confirmed_at,
      delivered_at: order.delivered_at,
      created_at: order.created_at,
      status_history: order.status_histories.map { |h| status_history_entry(h) }
    }
  end

  private

  attr_reader :order

  def status_history_entry(history)
    {
      status: history.status,
      note: history.note,
      changed_by: history.changed_by_user&.full_name,
      created_at: history.created_at
    }
  end
end
