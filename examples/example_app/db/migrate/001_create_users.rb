class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.text :bio
      t.timestamps
    end
    
    add_index :users, :email, unique: true
    add_index :users, :name
  end
end 