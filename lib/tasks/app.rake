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

namespace :app do
  desc "TODO"
  task :init => :environment do
    ActiveRecord::Base.connection.execute("TRUNCATE spree_taxonomies")
    ActiveRecord::Base.connection.execute("TRUNCATE spree_taxons")
    filename = Rails.root.join('lib', 'tasks', 'Masterfile_Winelist_retail_for_Weston', 'master-表格 1.csv')
    CSV.open(filename, :headers => true).each do |line|

      # create region taxon
      taxonomy, top_taxon = create_taxonomy('region')
      parent_id = [top_taxon.id]
      regions = [line[3], line[4], line[5], line[6]].compact!
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
        taxonomy, top_taxon = create_taxonomy('style')
        Spree::Taxon.find_or_create_by_parent_id_and_name(top_taxon.id,
                                                          line[2].strip,
                                                          :taxonomy_id => taxonomy.id,
                                                          :position => 0)
      end


      # create variety taxonomy
      taxonomy, top_taxon = create_taxonomy('variety')
      if line[14]
        line[14].gsub(/(\d(.+)?(\%|％))|,|\//, "").split("\n").each do |variety|
          Spree::Taxon.find_or_create_by_parent_id_and_name(top_taxon.id,
                                                            variety.strip,
                                                            :taxonomy_id => taxonomy.id,
                                                            :position => 0)
        end
      end


    end

  end

end
