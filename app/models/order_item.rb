# Immutable purchase-time snapshot (DECISION-009) — product_name_snapshot
# and unit_price_cents never change even if the underlying Product's name or
# price changes later. belongs_to :product stays required: products are only
# ever deactivated, never destroyed, while referenced by order_items
# (see Manager::ProductsController).
class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :product_name_snapshot, presence: true
  validates :unit_price_cents, :line_total_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
end
