module Carts
  # Backend's single source of truth for cart totals (AI_RULES.md §8) —
  # reused unchanged by Orders::Create at checkout so there is exactly one
  # calculation path, not a duplicated one (per CART-07's original intent).
  # No delivery charge/discount-code engine for the demo build (DECISION-030)
  # — just line items at each product's current effective price.
  class CalculateTotals
    Result = Struct.new(:subtotal_cents, :delivery_charge_cents, :discount_cents, :total_cents, keyword_init: true)

    def self.call(cart)
      new(cart).call
    end

    def initialize(cart)
      @cart = cart
    end

    def call
      subtotal = cart.cart_items.sum(&:line_total_cents)

      Result.new(
        subtotal_cents: subtotal,
        delivery_charge_cents: 0,
        discount_cents: 0,
        total_cents: subtotal
      )
    end

    private

    attr_reader :cart
  end
end
