class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :full_name, null: false
      t.string :phone
      # Plain string for now — DB-02 adds the check constraint restricting
      # this to the six fixed roles (DECISION-011).
      t.string :role, null: false, default: "customer"
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end
