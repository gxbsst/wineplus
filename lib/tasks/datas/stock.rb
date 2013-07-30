# Spree::Sample.load_sample("variants")

# location = Spree::StockLocation.find_by_name 'china'
# location.active = true
# location.country =  Spree::Country.where(iso: 'CN').first
# location.save!

ActiveRecord::Base.connection.execute("TRUNCATE spree_stock_movements")

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
    Spree::StockMovement.create!(:quantity => variants[variant.sku] || 0, :stock_item => stock_item)
  end
end
