# `unit_price_cents` is written at add/update time for auditability, but is
# never the authoritative number shown to the customer or totalled at
# checkout — `current_unit_price_cents`/`line_total_cents` always read
# Product#effective_price_cents live, so a price change after adding to
# cart is reflected immediately (AI_RULES.md §8). This is a live working
# price, not an immutable snapshot — that only happens at order_items
# creation (DECISION-009).
class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :product_id, uniqueness: { scope: :cart_id }

  def current_unit_price_cents
    product.effective_price_cents
  end

  def line_total_cents
    current_unit_price_cents * quantity
  end
end
