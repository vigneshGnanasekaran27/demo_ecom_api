class CreatePaymentEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :payment_events do |t|
      # Nullable — a webhook for an unrecognized/not-yet-linked payment must
      # still be recorded (BACKEND_RULES.md §15's "unknown payment" case).
      t.references :payment, foreign_key: true
      t.string :razorpay_event_id, null: false
      t.string :event_type, null: false
      t.jsonb :payload, null: false, default: {}
      t.datetime :processed_at

      # Immutable audit row — no updated_at, matching the plan's literal
      # "created_at" (not "timestamps").
      t.datetime :created_at, null: false
    end

    add_index :payment_events, :razorpay_event_id, unique: true
  end
end
