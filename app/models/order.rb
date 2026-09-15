# Matches the two DB CHECK constraints added in DB-14 (DECISION-019):
# order_status's full lifecycle (PROJECT_CONTEXT.md §10) and payment_status's
# four-value set. Snapshot shipping_* fields are immutable once created
# (DECISION-009) — never re-derived from a live Address record.
class Order < ApplicationRecord
  enum :order_status, {
    pending_payment: "pending_payment",
    confirmed: "confirmed",
    processing: "processing",
    packed: "packed",
    dispatched: "dispatched",
    out_for_delivery: "out_for_delivery",
    delivered: "delivered",
    cancelled: "cancelled"
  }, default: "pending_payment"

  enum :payment_status, {
    pending: "pending",
    successful: "successful",
    failed: "failed",
    refunded: "refunded"
  }, default: "pending"

  belongs_to :user, optional: true
  belongs_to :guest_session, optional: true
  has_many :order_items, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :status_histories, -> { order(:created_at) }, class_name: "OrderStatusHistory", dependent: :destroy

  validates :order_number, presence: true, uniqueness: true
  validates :shipping_name, :shipping_phone, :shipping_line1,
            :shipping_city, :shipping_state, :shipping_postal_code, presence: true
  validates :subtotal_cents, :total_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :exactly_one_owner

  before_validation :assign_order_number, on: :create

  private

  def exactly_one_owner
    owners = [ user_id, guest_session_id ].compact
    errors.add(:base, "must belong to exactly one of user or guest session") unless owners.size == 1
  end

  def assign_order_number
    return if order_number.present?

    # Human-readable and effectively unique (date + 6 random hex chars); the
    # DB unique index is still the real guarantee, this just avoids the rare
    # collision needing a retry in the vast majority of cases.
    self.order_number = "ORD-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(3).upcase}"
  end
end
