class AddIsCurrentToSpreeAddresses < ActiveRecord::Migration
  def change
    add_column :spree_addresses, :is_current, :boolean
  end
end
