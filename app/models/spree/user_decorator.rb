Spree::User.class_eval do
  has_many :addresses, class_name: 'Spree::Address'

  def remove_address_current
    addresses.each {|a| a.update_attribute(:is_current, false)}
  end

  def current_ship_address
 	addresses.current.try(:first)
  end

  def current_shipment_method
  	last_order = orders.order('completed_at DESC').complete.try(:first)
  	last_order ? last_order.shipment : false
  end

end