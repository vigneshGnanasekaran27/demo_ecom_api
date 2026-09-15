class CreateOffers < ActiveRecord::Migration[8.1]
  VALID_DISCOUNT_TYPES = %w[percent flat].freeze

  def change
    create_table :offers do |t|
      t.string :name, null: false
      t.string :discount_type, null: false
      # Whole number in both cases: a percent (0-100, matching products.discount_percent's
      # integer convention) or a flat amount in smallest-currency-unit (BACKEND_RULES.md §8).
      t.integer :discount_value, null: false
      t.datetime :starts_at
      t.datetime :ends_at
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_check_constraint :offers,
      "discount_type IN (#{VALID_DISCOUNT_TYPES.map { |type| "'#{type}'" }.join(', ')})",
      name: "offers_discount_type_check"
  end
end
