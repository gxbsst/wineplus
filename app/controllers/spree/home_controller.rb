module Spree
  class HomeController < Spree::StoreController
    helper 'spree/products'
    respond_to :html

    def index
      @red = Taxon.find_by_permalink!('categories/red')
      @white = Taxon.find_by_permalink!('categories/white')
      @sparkling = Taxon.find_by_permalink!('categories/white')

      @red_searcher = Spree::Config.searcher_class.new(params.merge(:taxon => @red.id))
      @reds = @red_searcher.retrieve_products.limit(5)

      @whites_searcher = Spree::Config.searcher_class.new(params.merge(:taxon => @white.id))
      @whites = @whites_searcher.retrieve_products

      @sparkling_searcher = Spree::Config.searcher_class.new(params.merge(:taxon => @sparkling.id))
      @sparklings = @sparkling_searcher.retrieve_products

      #@searcher = Spree::Config.searcher_class.new(params)
      #@searcher.current_user = try_spree_current_user
      #@searcher.current_currency = current_currency
      #@products = @searcher.retrieve_products
      #@whites =
      #@red =
      #@
    end
  end
end
