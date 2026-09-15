class CreateOrders < ActiveRecord::Migration[8.1]
  # PROJECT_CONTEXT.md §10 — the full order lifecycle; enforced again at the
  # model layer (valid transitions) in CHECKOUT-01/ORDER-01.
  VALID_ORDER_STATUSES = %w[
    pending_payment confirmed processing packed dispatched out_for_delivery delivered cancelled
  ].freeze
  VALID_PAYMENT_STATUSES = %w[pending successful failed refunded].freeze

  def change
    create_table :orders do |t|
      t.string :order_number, null: false
      t.references :user, foreign_key: true
      # guest_sessions.id is uuid (DB-04) — must match type.
      t.references :guest_session, type: :uuid, foreign_key: true

      # Money as integer smallest-currency-unit (BACKEND_RULES.md §8) — never floats.
      t.integer :subtotal_cents, null: false
      t.integer :discount_cents, null: false, default: 0
      t.integer :delivery_charge_cents, null: false, default: 0
      t.integer :total_cents, null: false

      # Flattened, immutable shipping-address snapshot (DECISION-009) — never a
      # FK to the mutable `addresses` row, mirrors that table's own columns.
      t.string :shipping_name, null: false
      t.string :shipping_phone, null: false
      t.string :shipping_line1, null: false
      t.string :shipping_line2
      t.string :shipping_city, null: false
      t.string :shipping_state, null: false
      t.string :shipping_postal_code, null: false
      t.string :shipping_country, null: false, default: "India"
      t.string :shipping_landmark

      t.string :razorpay_order_id
      t.string :razorpay_payment_id

      t.string :payment_status, null: false, default: "pending"
      t.string :order_status, null: false, default: "pending_payment"

      t.datetime :placed_at
      t.datetime :confirmed_at
      t.datetime :delivered_at

      t.timestamps
    end

    add_index :orders, :order_number, unique: true
    add_index :orders, :razorpay_order_id, unique: true
    add_index :orders, :order_status
    add_index :orders, :created_at

    add_check_constraint :orders,
      "order_status IN (#{VALID_ORDER_STATUSES.map { |status| "'#{status}'" }.join(', ')})",
      name: "orders_order_status_check"
    add_check_constraint :orders,
      "payment_status IN (#{VALID_PAYMENT_STATUSES.map { |status| "'#{status}'" }.join(', ')})",
      name: "orders_payment_status_check"
  end
end
