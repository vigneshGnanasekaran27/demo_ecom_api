# status matches Razorpay's own payment lifecycle vocabulary (DECISION-019
# update) — distinct from and more granular than orders.payment_status.
class Payment < ApplicationRecord
  enum :status, {
    created: "created",
    authorized: "authorized",
    captured: "captured",
    failed: "failed",
    refunded: "refunded"
  }, default: "created"

  belongs_to :order

  validates :amount_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
