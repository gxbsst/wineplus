# encoding: utf-8
require 'csv'

def create_taxonomy(name)
  taxonomy = Spree::Taxonomy.find_or_create_by_name(name)

  top_taxon = Spree::Taxon.find_or_create_by_parent_id_and_name(nil,
                                                                name,
                                                                :taxonomy_id => taxonomy.id,
                                                                :position => 0)
  return taxonomy, top_taxon
end

# return array OR nil
def parse_variety(line)
  return nil unless line[13].present?
  line[13].downcase.gsub(/(\d(.+)?(\%|％))|,|\//, "").split("\n")
end


namespace :app do

  def load_sample(file)
    path = File.expand_path(samples_path + "#{file}.rb")
    # Check to see if the specified file has been loaded before
    if !$LOADED_FEATURES.include?(path)
      require path
      puts "Loaded #{file.titleize} samples"
    end
  end

  def samples_path
    Pathname.new(Rails.root.join('lib', 'tasks', 'datas'))
  end

  desc 'Init Products Data'
  task :init_products => :environment do
   # load_sample("products") # DONE
   # load_sample("taxons") // DONE
   # load_sample("product_properties") //DONE
   # load_sample("prototypes") //DONE
   # load_sample("stock") // NOT DONE
   # load_sample("variants")
  load_sample("assets")
  end

  desc "TODO"
  task :init => :environment do
    ActiveRecord::Base.connection.execute("TRUNCATE spree_taxonomies")
    ActiveRecord::Base.connection.execute("TRUNCATE spree_taxons")
    # filename = Rails.root.join('lib', 'tasks', 'datas/images', 'btl.csv')
    CSV.open(filename, :headers => true).each do |line|

      # # create region taxon
      taxonomy, top_taxon = create_taxonomy('Region')
      parent_id = [top_taxon.id]
      regions = [line[3], line[4], line[5], line[6]].compact

      if regions
       regions.each do |i|
        
         taxon = Spree::Taxon.find_or_create_by_parent_id_and_name(parent_id.last,
                                                                   i.strip,
                                                                   :taxonomy_id => taxonomy.id,
                                                                   :position => 0)
         parent_id << taxon.id
       end
      end


      # create style taxon
      if line[2].present?
        taxonomy, top_taxon = create_taxonomy('Style')
        parent_id = [top_taxon.id]
        style = Spree::Taxon.find_or_create_by_parent_id_and_name(parent_id.last,
                                                          line[2].strip,
                                                          :taxonomy_id => taxonomy.id,
                                                          :position => 0)
        parent_id << style.id
      end


      # create variety taxonomy
      taxonomy, top_taxon = create_taxonomy('Variety')
      if parse_variety(line)
        parse_variety(line).each do |variety|
         taxon = Spree::Taxon.find_or_create_by_parent_id_and_name(top_taxon.id,
                                                            variety.strip,
                                                            :taxonomy_id => taxonomy.id,
                                                            :position => 0)
        end
      end


    end

  end

end
