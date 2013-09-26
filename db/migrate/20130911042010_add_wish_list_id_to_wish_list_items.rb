class AddWishListIdToWishListItems < ActiveRecord::Migration
  def change
    add_column :wish_list_items, :wish_list_id, :integer
  end
end
