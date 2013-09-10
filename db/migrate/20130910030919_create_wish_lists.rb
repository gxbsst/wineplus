class CreateWishLists < ActiveRecord::Migration
  def change
    create_table :wish_lists do |t|
      t.string :name
      t.references :user

      t.timestamps
    end
    add_index :wish_lists, :name
    add_index :wish_lists, :user_id
  end
end
