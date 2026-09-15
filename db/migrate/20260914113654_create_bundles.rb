class CreateBundles < ActiveRecord::Migration[8.1]
  def change
    create_table :bundles do |t|
      t.string :name
      t.references :primary_product, foreign_key: { to_table: :products }
      # Money as integer smallest-currency-unit (BACKEND_RULES.md §8) — never floats.
      t.integer :bundle_price_cents
      t.boolean :active, null: false, default: true

      t.timestamps
    end
  end
end
