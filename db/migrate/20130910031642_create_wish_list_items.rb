class CreateWishListItems < ActiveRecord::Migration
  def change
    create_table :wish_list_items do |t|
      t.references :user
      t.references :product

      t.timestamps
    end
    add_index :wish_list_items, :user_id
    add_index :wish_list_items, :product_id
  end
end
