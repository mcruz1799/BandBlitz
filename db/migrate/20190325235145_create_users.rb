class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :role, default: "member"
      t.string :password_digest
      t.integer :band_id
      t.boolean :active, default: true

      t.timestamps
    end
    # change_column :users, :role, :string, :default => "em"
  end
end
