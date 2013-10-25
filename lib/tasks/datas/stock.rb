# encoding: utf-8
# Spree::Sample.load_sample("variants")

# location = Spree::StockLocation.find_by_name 'china'
# location.active = true
# location.country =  Spree::Country.where(iso: 'CN').first
# location.save!

ActiveRecord::Base.connection.execute("TRUNCATE spree_stock_movements")
ActiveRecord::Base.connection.execute("TRUNCATE spree_stock_items")
ActiveRecord::Base.connection.execute("TRUNCATE spree_stock_locations")

Spree::StockLocation.first_or_create!({name: 'China', 
	address1: 'Shanghai',
	address2: 'Shanghai',
	city: 'Shanghai',
	state_id: 55,
	state_name: '上海',
	country_id: 119,
	zipcode: 200000,
	phone: 18621699591,
	active: true})

filename = Rails.root.join('lib', 'tasks', 'datas', 'btl.csv')

variants = {}
variants = CSV.open(filename, :headers => true).inject({}) do |memo,line|
  if line[0].present? && line[0].downcase == 'on' && line[25].present? && line[26] !=0
  	memo[line[7]] = line[26].to_i
   	variants.merge(memo)
  end
  variants
end

Spree::Variant.all.each do |variant|
  variant.stock_items.each do |stock_item|
  	puts variants[variant.sku]
    Spree::StockMovement.create!(:quantity => 1000, :stock_item => stock_item)
    stock_item.adjust_count_on_hand(1000 || 0)
  end
end
