Spree::Order.class_eval do

	def init_address(current_ship_address)
		# update_attributes(address_params(current_ship_address))
		self.ship_address = current_ship_address
		self.bill_address = current_ship_address.clone
		self
	end

	def init_shipment_mehtod(shipment_mehtod)
		update_attributes(shipment_params(shipment_mehtod))
	end

	def shipment_params(shipment_mehtod)
		params ||= {}
		params[:shipments_attributes] = {}

		sr = shipment_mehtod.shipping_rates
		sub_params = {}.tap do |h|
			sr.each {|i| h['0'] = {'selected_shipping_rate_id' => i.id, 'id' => i.shipment_id } }
		end
		params[:shipments_attributes] = sub_params.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
		params
	end

	def address_params(current_address)
		params ||= {}
		sub_params = current_address.attributes.slice!('id', 'created_at', 'updated_at')
		params[:ship_address_attributes] = sub_params.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
		params
	end

end