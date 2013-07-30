# encoding: utf-8
# Spree::Sample.load_sample("tax_categories")
# require Rails.root.join('lib/tasks/datas', 'tax_categories.rb')

style = Spree::TaxCategory.find_by_name!("China")

def wine_price(line)
  line[25].gsub(/[CN¥,]/,'').strip.try(:to_f)  if line[25].present?
end


default_attrs = {
  :description => Faker::Lorem.paragraph,
  :available_on => Time.zone.now
}

ActiveRecord::Base.connection.execute("TRUNCATE spree_products")
ActiveRecord::Base.connection.execute("TRUNCATE spree_variants")

filename = Rails.root.join('lib', 'tasks', 'datas', 'btl.csv')
products = []

CSV.open(filename, :headers => true).each do |line|
  if line[0].present? && line[0].downcase == 'on' && line[25].present?
    products << { name: line[9], tax_category: style, price: wine_price(line), sku: line[7]}
  end
end

products.each do |product_attrs|
  eur_price = product_attrs.delete(:eur_price)
  Spree::Config[:currency] = "CNY"

  default_shipping_category = Spree::ShippingCategory.find_by_name!("wine")
  product = Spree::Product.new(default_attrs.merge(product_attrs), :without_protection => true)
  # Spree::Config[:currency] = "EUR"
  # product.reload
  # product.price = eur_price
  product.shipping_category = default_shipping_category
  puts product.name
  product.master.cost_price = product.price
  product.master.sku = product_attrs[:sku]
  product.save!
end

# Spree::Config[:currency] = "CNY"
