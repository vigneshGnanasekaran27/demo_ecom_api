class CreatePayments < ActiveRecord::Migration[8.1]
  # Razorpay's own payment lifecycle terminology, per PAYMENT-03/PROJECT_CONTEXT.md
  # §9 — distinct from orders.payment_status (DECISION-019), which is a simpler
  # order-level summary.
  VALID_STATUSES = %w[created authorized captured failed refunded].freeze

  def change
    create_table :payments do |t|
      t.references :order, null: false, foreign_key: true
      t.string :razorpay_order_id
      t.string :razorpay_payment_id
      t.string :razorpay_signature
      # Money as integer smallest-currency-unit (BACKEND_RULES.md §8) — never floats.
      t.integer :amount_cents, null: false
      t.string :status, null: false, default: "created"
      t.jsonb :raw_response

      t.timestamps
    end

    add_index :payments, :razorpay_payment_id

    add_check_constraint :payments,
      "status IN (#{VALID_STATUSES.map { |status| "'#{status}'" }.join(', ')})",
      name: "payments_status_check"
  end
end
