# encoding: utf-8
# Spree::Sample.load_sample("tax_categories")
# require Rails.root.join('lib/tasks/datas', 'tax_categories.rb')

style = Spree::TaxCategory.find_by_name!("China")

def parse_variety(line)
  return nil unless line[13].present?
  line[13].downcase.split("\n")
end


def wine_price(line)
  line[26].gsub(/[CN¥,]/,'').strip.try(:to_f).try(:round)  if line[26].present?
end


def join_region(line)
  a = [line[3], line[4], line[5], line[6]].compact
  a.join(" > ")
end

default_attrs = {
  :description => Faker::Lorem.paragraph,
  :available_on => Time.zone.now
}

ActiveRecord::Base.connection.execute("TRUNCATE spree_products")
ActiveRecord::Base.connection.execute("TRUNCATE spree_variants")
ActiveRecord::Base.connection.execute("TRUNCATE grape_varieties")

filename = Rails.root.join('lib', 'tasks', 'datas', 'btl.csv')
products = []

CSV.open(filename, :headers => true).each do |line|
  if line[0].present? && line[0].downcase == 'on' && line[1].downcase == 'by_btl' && line[26].present?
    style_id = Spree::Taxon.find_by_name(line[2]).try(:id)
    products << { name: line[9], 
      tax_category: style, 
      price: wine_price(line), 
      sku: line[7], 
      :style_id => style_id,
      :varieties => parse_variety(line),
      :description => line[19], :region_en => join_region(line)}
  end
end

products.each do |product_attrs|
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

  # 葡萄酒品种
  if product_attrs[:varieties].present?
    product_attrs[:varieties].each do |grape_variety| 
      r = grape_variety.split("/")
      GrapeVariety.create(product_id: product.id,  name_zh: r[0], name_en: r[0].try(:to_url), origin_name: r[0], percent: r[1]  ) if r[0].present?
    end
  end
end

Spree::Config[:currency] = "CNY"
