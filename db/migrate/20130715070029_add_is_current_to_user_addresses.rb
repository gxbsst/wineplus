class AddIsCurrentToUserAddresses < ActiveRecord::Migration
  def change
    add_column :user_addresses, :is_current, :boolean
  end
end
