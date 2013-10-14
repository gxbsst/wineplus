# Spree::Sample.load_sample("products")
# Spree::Sample.load_sample("variants")

products = {}
# products[:ror_baseball_jersey] = Spree::Product.find_by_name!("Ruby on Rails Baseball Jersey") 
# products[:ror_tote] = Spree::Product.find_by_name!("Ruby on Rails Tote")
# products[:ror_bag] = Spree::Product.find_by_name!("Ruby on Rails Bag")
# products[:ror_jr_spaghetti] = Spree::Product.find_by_name!("Ruby on Rails Jr. Spaghetti")
# products[:ror_mug] = Spree::Product.find_by_name!("Ruby on Rails Mug")
# products[:ror_ringer] = Spree::Product.find_by_name!("Ruby on Rails Ringer T-Shirt")
# products[:ror_stein] = Spree::Product.find_by_name!("Ruby on Rails Stein")
# products[:spree_baseball_jersey] = Spree::Product.find_by_name!("Spree Baseball Jersey")
# products[:spree_stein] = Spree::Product.find_by_name!("Spree Stein")
# products[:spree_jr_spaghetti] = Spree::Product.find_by_name!("Spree Jr. Spaghetti")
# products[:spree_mug] = Spree::Product.find_by_name!("Spree Mug")
# products[:spree_ringer] = Spree::Product.find_by_name!("Spree Ringer T-Shirt")
# products[:spree_tote] = Spree::Product.find_by_name!("Spree Tote")
# products[:spree_bag] = Spree::Product.find_by_name!("Spree Bag")
# products[:ruby_baseball_jersey] = Spree::Product.find_by_name!("Ruby Baseball Jersey")
# products[:apache_baseball_jersey] = Spree::Product.find_by_name!("Apache Baseball Jersey")


def image(sku)
    attachments = []
    image_directory = Rails.root.join('lib','tasks', 'datas/images')
    path = image_directory.join("#{sku}.png")
    if File.exist?(path)
      attachments << {:attachment => File.open(path)}
    end

    (1..5).to_a.each do |i|

      path2 = image_directory.join("#{sku}-#{i}.png")

      if File.exist?(path2)
        attachments << {:attachment => File.open(path2)}
      end

    end

    # File.open("miss_image_sku.txt", "a+") do |io|  
    #   miss_image_sku.each do |sku| 
    #     io.puts "sku\n"
    #   end
    # end

    attachments    
end


filename = Rails.root.join('lib', 'tasks', 'datas', 'btl.csv')

images = {}

file =  File.open("miss_image_sku.txt", "a+") 

images = CSV.open(filename, :headers => true).inject({}) do |memo,line|
  if line[0].present? && line[0].downcase == 'on'  #&& line[21].present? && line[20].present?
    product = Spree::Product.find_by_name(line[9])
    if product.present? && image(line[7]).present?
      memo[product.master] = image(line[7])
      images.merge(memo)
    end    
  end

  file.puts "#{line[9]} -  #{line[7]} \n" if !image(line[7]).present?

  images
end

# products[:ror_baseball_jersey].variants.each do |variant|
#   color = variant.option_value("tshirt-color").downcase
#   main_image = image("ror_baseball_jersey_#{color}", "png")
#   variant.images.create!(:attachment => main_image)
#   back_image = image("ror_baseball_jersey_back_#{color}", "png")
#   if back_image
#     variant.images.create!(:attachment => back_image)
#   end
# end
images.each do |variant, attachments|
  attachments.each do |attachment|
    variant.images.create!(attachment)
  end
end

