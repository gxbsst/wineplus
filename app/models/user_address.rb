# encoding: utf-8

class UserAddress <  ActiveRecord::Base

  SHIPPING_STATUS = 1
  BILLING_STATUS = 2

  attr_accessor :user_id, :address_id, :status, :is_current

  if Spree.user_class
    belongs_to :user, class_name: Spree.user_class.to_s
  else
    belongs_to :user
  end

  belongs_to :address, :class_name => Spree::Address

  def self.all_shipping_address(user)
     joins(:address).where(user_id: user.id, status: SHIPPING_STATUS).try(:collect, &:address)
  end

  delegate :firstname, :lastname, :address1, :address2, :city, :country, :zipcode, :phone, :state_name, :company, to: :address

  def full_address
    "#{firstname} #{lastname} #{address1} #{city} #{country}"
  end

end