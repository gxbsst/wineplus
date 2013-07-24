module UserHelper
	def link_to_edit_account(text, cname, aname)
		current = aname == 'edit' ? 'current4' : ''
		link_to text, spree.edit_account_path, :class => current
	end

	def link_to_my_orders(text, cname, aname)
		current = (aname == 'orders' || cname == 'orders' )? 'current4' : ''
		link_to text,  '/account/orders', :class => current
	end
end