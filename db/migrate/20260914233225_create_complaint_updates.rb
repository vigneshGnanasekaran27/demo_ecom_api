class CreateComplaintUpdates < ActiveRecord::Migration[8.1]
  # Same fixed set as complaints.status (DB-19) — a history row can't record a
  # status the complaint itself couldn't hold.
  VALID_STATUSES = %w[open under_review in_progress resolved closed].freeze

  def change
    create_table :complaint_updates do |t|
      t.references :complaint, null: false, foreign_key: true
      t.string :status, null: false
      t.text :note
      # No "(nullable)" qualifier in the plan, matching complaints.user_id
      # (DB-19) — every update is attributable to the admin who made it.
      t.references :updated_by_user, null: false, foreign_key: { to_table: :users }

      # Immutable audit row — no updated_at, matching the plan's literal
      # "created_at" (not "timestamps").
      t.datetime :created_at, null: false
    end

    add_check_constraint :complaint_updates,
      "status IN (#{VALID_STATUSES.map { |status| "'#{status}'" }.join(', ')})",
      name: "complaint_updates_status_check"
  end
end
