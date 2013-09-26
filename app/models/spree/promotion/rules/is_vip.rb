module Spree
	class Promotion
		module Rules
			class IsVip < PromotionRule
				def eligible?(order, options = {})
				  user = order.try(:user) || options[:user]
				  user.vip? ? true : false
				end
			end
		end
	end
end