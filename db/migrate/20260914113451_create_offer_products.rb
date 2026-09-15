class CreateOfferProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :offer_products do |t|
      t.references :offer, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
    end

    add_index :offer_products, [ :offer_id, :product_id ], unique: true
  end
end
