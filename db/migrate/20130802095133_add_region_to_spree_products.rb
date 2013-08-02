class AddRegionToSpreeProducts < ActiveRecord::Migration
  def change
    add_column :spree_products, :region_en, :string
    add_column :spree_products, :region_cn, :string
  end
end
