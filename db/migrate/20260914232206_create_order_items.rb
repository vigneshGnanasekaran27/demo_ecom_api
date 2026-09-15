class CreateOrderItems < ActiveRecord::Migration[8.1]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      # Purchase-time snapshot (DECISION-009) — must stay accurate even if the
      # product's name/price changes or the product is later deactivated.
      t.string :product_name_snapshot, null: false
      t.integer :unit_price_cents, null: false
      t.integer :quantity, null: false, default: 1
      t.integer :discount_cents, null: false, default: 0
      t.integer :line_total_cents, null: false
    end
  end
end
