# encoding: utf-8
filename = Rails.root.join('lib', 'tasks', 'datas', 'btl.csv')
products = {}

def wine_price(line)
  line[26].gsub(/[CN¥,]/,'').strip.try(:to_f)  if line[26].present?
end

ActiveRecord::Base.connection.execute("TRUNCATE spree_product_properties")
ActiveRecord::Base.connection.execute("TRUNCATE spree_properties")

products = CSV.open(filename, :headers => true).inject({}) do |memo, line|
  if line[0].present? && line[0].downcase == 'on' && line[26].present?
    memo[line[9]] = {
      'Vintage' => line[8],
      'Capacity' => line[11],
      'Rating' => line[14],
      'EnotecaPrice' => wine_price(line),
      'NameZh' => line[10]
    }
    products.merge(memo)
  end
  products
end



products.each do |name, properties|
  product = Spree::Product.find_by_name(name)
  if product
    properties.each do |prop_name, prop_value|
      product.set_property(prop_name, prop_value)
    end
  end
end
