class OrderItemSerializer
  def initialize(order_item)
    @order_item = order_item
  end

  def as_json(*)
    {
      id: order_item.id,
      product_id: order_item.product_id,
      product_name: order_item.product_name_snapshot,
      unit_price_cents: order_item.unit_price_cents,
      quantity: order_item.quantity,
      discount_cents: order_item.discount_cents,
      line_total_cents: order_item.line_total_cents
    }
  end

  private

  attr_reader :order_item
end
