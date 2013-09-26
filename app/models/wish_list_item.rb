class WishListItem < ActiveRecord::Base
  belongs_to :user
  belongs_to :product
  attr_accessible :user_id, :product_id, :wish_list_id
end
