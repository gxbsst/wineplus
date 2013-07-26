filename = Rails.root.join('lib', 'tasks', 'datas/images', 'btl.csv')
products = {}

products = CSV.open(filename, :headers => true).inject({}) do |memo, line|
  if line[0].present? && line[0].downcase == 'on' && line[21].present?
    memo[line[9]] = {
      'Vintage' => line[8],
      'Capacity' => line[11],
      'Rating' => line[14]
    }
    products.merge(memo)
  end
  products
end

products.each do |name, properties|
  product = Spree::Product.find_by_name(name)
  properties.each do |prop_name, prop_value|
    product.set_property(prop_name, prop_value)
  end
end
