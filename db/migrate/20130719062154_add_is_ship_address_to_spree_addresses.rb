class AddIsShipAddressToSpreeAddresses < ActiveRecord::Migration
  def change
    add_column :spree_addresses, :is_ship_address, :boolean
  end
end
