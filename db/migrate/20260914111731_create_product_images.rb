class CreateProductImages < ActiveRecord::Migration[8.1]
  def change
    create_table :product_images do |t|
      t.references :product, null: false, foreign_key: true
      t.integer :position, null: false, default: 0
      t.string :alt_text

      t.timestamps
    end
  end
end
