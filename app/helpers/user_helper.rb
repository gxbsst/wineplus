module UserHelper
	def link_to_edit_account(text, cname, aname)
		current = (aname == 'edit' && cname == 'users') ? 'current4' : ''
		link_to text, spree.edit_account_path, :class => current
	end

	def link_to_my_orders(text, cname, aname)
		current = (aname == 'orders' || cname == 'orders' )? 'current4' : ''
		
		url = '/account/orders'
		
		link_to text,  url, :class => current
	end

	def link_to_address(text, cname, aname)
		current = (cname == 'addresses' )? 'current4' : ''
		link_to text, account_addresses_path, :class => current
	end
end