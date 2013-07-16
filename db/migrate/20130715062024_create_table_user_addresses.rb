class CreateTableUserAddresses < ActiveRecord::Migration
  def up
    create_table :user_addresses do |t|
     t.integer :user_id
     t.integer :address_id
     t.integer :status
     t.timestamps
    end
  end

  def down
    drop_table :user_addresses
  end
end
