class CreateCarts < ActiveRecord::Migration[8.1]
  # DECISION-013: abandoned-cart tracking is a status on carts, not a separate table.
  VALID_STATUSES = %w[active abandoned converted].freeze

  def change
    create_table :carts do |t|
      t.references :user, foreign_key: true
      # guest_sessions.id is uuid (DB-04) — must match type.
      t.references :guest_session, type: :uuid, foreign_key: true
      t.string :status, null: false, default: "active"
      t.datetime :checkout_started_at
      t.datetime :payment_started_at

      t.timestamps
    end

    add_check_constraint :carts,
      "status IN (#{VALID_STATUSES.map { |status| "'#{status}'" }.join(', ')})",
      name: "carts_status_check"
  end
end
