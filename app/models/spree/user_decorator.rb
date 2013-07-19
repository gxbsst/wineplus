Spree::User.class_eval do

  has_many :addresses

  def ship_address
    addresses.where(is_ship_address: true)
  end

  def bill_address
    addresses.where(is_ship_address: false)
  end

  def remove_address_current
    addresses.each {|a| a.update_attribute(:is_current, false)}
  end

  def current_shipment_method
  	last_order = orders.order('completed_at DESC').complete.try(:first)
  	last_order ? last_order.shipment : false
  end

  def current_ship_address
    ship_address.try(:current).try(:first)
  end

end