class CreateOrderStatusHistories < ActiveRecord::Migration[8.1]
  # Same fixed set as orders.order_status (DB-14/PROJECT_CONTEXT.md §10) — a
  # history row can never record a status the order itself couldn't hold.
  VALID_ORDER_STATUSES = %w[
    pending_payment confirmed processing packed dispatched out_for_delivery delivered cancelled
  ].freeze

  def change
    create_table :order_status_histories do |t|
      t.references :order, null: false, foreign_key: true
      t.string :status, null: false
      t.references :changed_by_user, foreign_key: { to_table: :users }
      t.text :note

      # Immutable audit row — no updated_at, matching the plan's literal
      # "created_at" (not "timestamps").
      t.datetime :created_at, null: false
    end

    add_check_constraint :order_status_histories,
      "status IN (#{VALID_ORDER_STATUSES.map { |status| "'#{status}'" }.join(', ')})",
      name: "order_status_histories_status_check"
  end
end
