class CreateCartItems < ActiveRecord::Migration[8.1]
  def change
    create_table :cart_items do |t|
      t.references :cart, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity, null: false, default: 1
      # Snapshot of product price when added — money as integer cents (BACKEND_RULES.md §8).
      t.integer :unit_price_cents, null: false

      t.timestamps
    end
  end
end
