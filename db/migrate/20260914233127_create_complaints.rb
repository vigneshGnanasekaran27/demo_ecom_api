class CreateComplaints < ActiveRecord::Migration[8.1]
  # BACKEND_RULES.md §21 / PROJECT_CONTEXT.md §12.
  VALID_TYPES = %w[damaged wrong_product missing_product delivery_issue payment_issue other].freeze
  VALID_STATUSES = %w[open under_review in_progress resolved closed].freeze

  def change
    create_table :complaints do |t|
      t.references :order, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :complaint_type, null: false
      t.text :description, null: false
      t.string :status, null: false, default: "open"
      t.text :resolution_note

      t.timestamps
    end

    add_check_constraint :complaints,
      "complaint_type IN (#{VALID_TYPES.map { |type| "'#{type}'" }.join(', ')})",
      name: "complaints_complaint_type_check"
    add_check_constraint :complaints,
      "status IN (#{VALID_STATUSES.map { |status| "'#{status}'" }.join(', ')})",
      name: "complaints_status_check"
  end
end
