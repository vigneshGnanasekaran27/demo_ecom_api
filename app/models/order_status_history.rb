# Audit trail row for one order_status transition (ORDER-01). No
# "previous status" column by design — the sequence of rows over time
# already encodes that; each row just records the state the order moved
# *into*, who changed it (nil for a system-driven transition, e.g. payment
# confirmation), and an optional note.
class OrderStatusHistory < ApplicationRecord
  belongs_to :order
  belongs_to :changed_by_user, class_name: "User", optional: true

  validates :status, presence: true, inclusion: { in: Order.order_statuses.keys }
end
