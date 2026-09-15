class CreateGuestSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :guest_sessions, id: :uuid do |t|
      t.string :token, null: false
      t.string :email
      t.string :phone
      t.references :user, foreign_key: true
      t.datetime :first_seen_at, null: false
      t.datetime :last_seen_at, null: false

      t.timestamps
    end

    add_index :guest_sessions, :token, unique: true
  end
end
