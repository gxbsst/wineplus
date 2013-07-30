# encoding: utf-8
# Spree::Sample.load_sample("option_values")
# Spree::Sample.load_sample("products")



def wine_price(line)
  if line[25].present?
    line[25].gsub(/[CN¥,]/,'').strip.try(:to_i)  
  else
    nil
  end
end

filename = Rails.root.join('lib', 'tasks', 'datas', 'btl.csv')
# masters = {}

# masters = CSV.open(filename, :headers => true).inject({}) do |memo,line|
#   if line[0].present? && line[0].downcase == 'on' && line[21].present? && line[9].present?
#     product = Spree::Product.find_by_name(line[9])
#     masters[product] = {:cost_price => wine_price(line), :sku => line[7].strip}

#   end
#   masters
# end
# masters.each do |product, variant_attrs|
#   product.master.update_attributes!(variant_attrs)
# end

variants = []
 CSV.open(filename, :headers => true).inject({}) do |memo,line|
  if line[0].present? && line[0].downcase == 'on' && wine_price(line) && wine_price(line) != 0 && line[9].present?
      puts  wine_price(line) 
      product = Spree::Product.find_by_name(line[9])
      variants << {:product => product,:cost_price => wine_price(line), :price => wine_price(line), :sku => line[7].strip} 
  end
end


variants.each do |variant_attrs|
  begin
    Spree::Variant.create!(variant_attrs, :without_protection => true)
  rescue Exception => e
    puts e
    puts variant_attrs 
  end
  
end




