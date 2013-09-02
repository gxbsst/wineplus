class GrapeVariety < ActiveRecord::Base
	belongs_to :product, :class_name => 'Spree::Product', :foreign_key => 'product_id'
	attr_accessible :name_zh, :name_en, :origin_name, :percent, :product_id

	def self.multy_create(array)
		array.each do |item|
			create(item)
		end
	end
end