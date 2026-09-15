# Wraps the cart's items with the backend-calculated totals
# (Carts::CalculateTotals) — the frontend never computes these itself
# (AI_RULES.md §8).
class CartSerializer
  def initialize(cart)
    @cart = cart
    @totals = Carts::CalculateTotals.call(cart)
  end

  def as_json(*)
    {
      id: cart.id,
      status: cart.status,
      items: cart.cart_items.map { |item| CartItemSerializer.new(item).as_json },
      subtotal_cents: totals.subtotal_cents,
      delivery_charge_cents: totals.delivery_charge_cents,
      discount_cents: totals.discount_cents,
      total_cents: totals.total_cents
    }
  end

  private

  attr_reader :cart, :totals
end
