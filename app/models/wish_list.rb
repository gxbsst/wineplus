class WishList < ActiveRecord::Base

  # include ActiveModel::ForbiddenAttributesProtection

  attr_accessor :name , :user_id
  attr_accessible :name, :user_id

  belongs_to :user
  has_many :wish_list_items, dependent: :destroy

  def owner_by?(owner)
  	(owner && owner.id == user_id ) ? true : false
  end

end
