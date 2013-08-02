class AddStyleIdToSpreeProduct < ActiveRecord::Migration
  def change
    add_column :spree_products, :style_id, :integer
  end
end
