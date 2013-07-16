Spree::User.class_eval do
  has_many :addresses, class_name: 'Spree::Address'

  def remove_address_current
    addresses.each {|a| a.update_attribute(:is_current, false)}
  end
end