prototypes = [
  {
    :name => "Wine",
    :properties => ["Vintage", "Capacity", "Rating", "NameZh", 'EnotecaPrice']
  }
 
]

prototypes.each do |prototype_attrs|
  prototype = Spree::Prototype.create!(:name => prototype_attrs[:name])
  prototype_attrs[:properties].each do |property|
    prototype.properties << Spree::Property.find_by_name!(property)
  end
end
