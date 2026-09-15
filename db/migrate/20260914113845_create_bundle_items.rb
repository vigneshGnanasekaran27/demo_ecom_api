class CreateBundleItems < ActiveRecord::Migration[8.1]
  def change
    create_table :bundle_items do |t|
      t.references :bundle, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :position, null: false, default: 0
    end
  end
end
