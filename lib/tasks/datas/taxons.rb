# encoding: utf-8
# Spree::Sample.load_sample("taxonomies")
# Spree::Sample.load_sample("products")
require Rails.root.join('lib/tasks/datas', 'taxonomies.rb')

style = Spree::Taxonomy.find_by_name!("Style")
region = Spree::Taxonomy.find_by_name!("Region")
variety = Spree::Taxonomy.find_by_name!("Variety")

# to_permalink_word
def to_word(region)
  return nil unless region.present?
  region.to_url
end

def to_region_permalink(line)
  ['region',to_word(line[3]), 
  to_word(line[4]), 
  to_word(line[5]),
  to_word(line[6])].compact.join('/')
end

# return array OR nil
def parse_variety(line)
  return nil unless line[13].present?
  line[13].downcase.gsub(/(\d(.+)?(\%|％))|,|\//, "").split("\n")
end

filename = Rails.root.join('lib', 'tasks', 'datas/images', 'btl.csv')

# REGION
region_taxon_with_products = {}

region_taxon_with_products = CSV.open(filename, :headers => true).inject({}) do |memo, line|
  permalink = to_region_permalink(line)
  region_taxon_with_products[permalink] ||= {}
  region_taxon_with_products[permalink][:products] ||= []
  product = Spree::Product.find_by_name(line[9])
  region_taxon_with_products[permalink][:products] << product if product
  region_taxon_with_products.merge(region_taxon_with_products)
end



region_taxon_with_products.each do |k,v|
  taxon = Spree::Taxon.find_by_permalink(k)
  taxon.products = v[:products]
  taxon.save
end

# STYLE

style_taxon_with_products = {}

style_taxon_with_products = CSV.open(filename, :headers => true).inject({}) do |memo, line|
  permalink = ['style',to_word(line[2])].join('/')
  style_taxon_with_products[permalink] ||= {}
  style_taxon_with_products[permalink][:products] ||= []
  product = Spree::Product.find_by_name(line[9])
  style_taxon_with_products[permalink][:products] << product if product
  style_taxon_with_products.merge(style_taxon_with_products)
end


style_taxon_with_products.each do |k,v|
  taxon = Spree::Taxon.find_by_permalink(k)
  if taxon
    taxon.products = v[:products]
    taxon.save
  end
end

# VARIETY

variety_taxon_with_products = {}
variety_taxon_with_products = CSV.open(filename, :headers => true).inject({}) do |memo, line|
  variety = parse_variety(line)
  if variety
    permarlinks = variety.collect{|v| "variety/#{v.to_url}"}

    permarlinks.each do |permalink|
      variety_taxon_with_products[permalink] ||= {}
      variety_taxon_with_products[permalink][:products] ||= []
      product = Spree::Product.find_by_name(line[9])
      variety_taxon_with_products[permalink][:products] << product if product
      variety_taxon_with_products.merge(variety_taxon_with_products)
    end

  end
  variety_taxon_with_products
end

variety_taxon_with_products.each do |k,v|
  taxon = Spree::Taxon.find_by_permalink(k)
  if taxon
    taxon.products = v[:products]
    taxon.save
  end
end





# CSV.open(filename, :headers => true).each do |line|

#   # Region
#   region_permalink = to_region_permalink(line)
#   if region_permalink
#     region_taxon = Spree::Taxon.find_by_permalink(region_permalink)

#     # 必须要找到很多产品
#     product = Spree::Product.find_by_name(line[9])
#     region_taxon.products = [product]
#     region_taxon.save
#   end

#   # Style
#   style_permalink = to_word(line[2])
#   if style_permalink
#     taxon = Spree::Taxon.find_by_permalink(style_permalink)
#     product = Spree::Product.find_by_name(line[9])
#     taxon.products = [product]
#     taxon.save
#   end

#   # Variety 
#   variety_permalink = parse_variety(line) # be array or nil
#   if variety_permalink
#     variety_permalink.each do |vp|
#       taxon = Spree::Taxon.find_by_permalink(vp)
#       product = Spree::Product.find_by_name(line[9])
#       taxon.products = [product]
#     end
#   end

# end







# products = { 
#   :ror_tote => "Ruby on Rails Tote",
#   :ror_bag => "Ruby on Rails Bag",
#   :ror_mug => "Ruby on Rails Mug",
#   :ror_stein => "Ruby on Rails Stein",
#   :ror_baseball_jersey => "Ruby on Rails Baseball Jersey",
#   :ror_jr_spaghetti => "Ruby on Rails Jr. Spaghetti",
#   :ror_ringer => "Ruby on Rails Ringer T-Shirt",
#   :spree_stein => "Spree Stein",
#   :spree_mug => "Spree Mug",
#   :spree_ringer => "Spree Ringer T-Shirt",
#   :spree_baseball_jersey =>  "Spree Baseball Jersey",
#   :spree_tote => "Spree Tote",
#   :spree_bag => "Spree Bag",
#   :spree_jr_spaghetti => "Spree Jr. Spaghetti",
#   :apache_baseball_jersey => "Apache Baseball Jersey",
#   :ruby_baseball_jersey => "Ruby Baseball Jersey",
# }


# products.each do |key, name|
#   products[key] = Spree::Product.find_by_name!(name)
# end

# taxons = [
#   {
#     :name => "Categories",
#     :taxonomy => categories,
#     :position => 0
#   },
#   {
#     :name => "Bags",
#     :taxonomy => categories,
#     :parent => "Categories",
#     :position => 1,
#     :products => [
#       products[:ror_tote],
#       products[:ror_bag],
#       products[:spree_tote],
#       products[:spree_bag]
#     ]
#   },
#   {
#     :name => "Mugs",
#     :taxonomy => categories,
#     :parent => "Categories",
#     :position => 2,
#     :products => [
#       products[:ror_mug],
#       products[:ror_stein],
#       products[:spree_stein],
#       products[:spree_mug]
#     ]
#   },
#   {
#     :name => "Clothing",
#     :taxonomy => categories,
#     :parent => "Categories" 
#   },
#   {
#     :name => "Shirts",
#     :taxonomy => categories,
#     :parent => "Clothing",
#     :position => 0,
#     :products => [
#       products[:ror_jr_spaghetti],
#       products[:spree_jr_spaghetti]
#     ]
#   },
#   {
#     :name => "T-Shirts",
#     :taxonomy => categories,
#     :parent => "Clothing" ,
#     :products => [
#       products[:ror_baseball_jersey],
#       products[:ror_ringer],
#       products[:apache_baseball_jersey],
#       products[:ruby_baseball_jersey],
#       products[:spree_baseball_jersey],
#       products[:spree_ringer]
#     ],
#     :position => 0
#   },
#   {
#     :name => "Brands",
#     :taxonomy => brands
#   },
#   {
#     :name => "Ruby",
#     :taxonomy => brands,
#     :parent => "Brand" 
#   },
#   {
#     :name => "Apache",
#     :taxonomy => brands,
#     :parent => "Brand" 
#   },
#   {
#     :name => "Spree",
#     :taxonomy => brands,
#     :parent => "Brand"
#   },
#   {
#     :name => "Rails",
#     :taxonomy => brands,
#     :parent => "Brand"
#   },
# ]

# taxons.each do |taxon_attrs|
#   if taxon_attrs[:parent]
#     taxon_attrs[:parent] = Spree::Taxon.find_by_name!(taxon_attrs[:parent])
#   end
#   Spree::Taxon.create!(taxon_attrs, :without_protection => true)
# end
