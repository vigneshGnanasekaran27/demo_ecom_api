class Product < ApplicationRecord
  # Plain string at the DB layer (DB-06 — no CHECK constraint, unlike most
  # other status columns in this schema) — validity is enforced here instead.
  VALID_STATUSES = %w[active inactive].freeze

  belongs_to :category
  has_many :product_images, -> { order(:position) }, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :sku, presence: true, uniqueness: true
  validates :price_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :discount_percent, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :stock_quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :status, inclusion: { in: VALID_STATUSES }

  scope :active, -> { where(status: "active") }
  scope :in_stock, -> { where("stock_quantity > 0") }

  # Backend's authoritative discounted unit price (AI_RULES.md §8) — mirrors
  # demo_ecom_web/lib/format.ts#discountedPriceCents' rounding exactly so the
  # frontend's display and the backend's cart/order totals never disagree.
  def effective_price_cents
    return price_cents if discount_percent.zero?

    (price_cents * (100 - discount_percent) / 100.0).round
  end
end
