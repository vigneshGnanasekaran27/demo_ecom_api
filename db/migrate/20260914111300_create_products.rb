class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.references :category, null: false, foreign_key: true
      t.string :name, null: false
      t.string :slug, null: false
      t.string :sku, null: false
      t.text :description
      # Money as integer smallest-currency-unit (BACKEND_RULES.md §8) — never floats.
      t.integer :price_cents, null: false
      t.integer :discount_percent, null: false, default: 0
      t.integer :stock_quantity, null: false, default: 0
      # Plain string for now — validity enforced at the model layer (PRODUCT-04),
      # matching how `status`/enum-like columns are handled unless a dedicated
      # DB task (like DB-02 for users.role) calls for a DB-level constraint.
      t.string :status, null: false, default: "active"
      t.jsonb :specifications, null: false, default: {}
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :products, :slug, unique: true
    add_index :products, :sku, unique: true
  end
end
