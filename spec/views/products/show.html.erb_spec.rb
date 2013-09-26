require "spec_helper"

describe "spree/products/show.html.erb" do

  before :each do 
  	# assign(:image, stub_model(Spree::Image))
  	assign(:product, stub_model(Spree::Product, name: "Product Name", available_on: '2011-10-10 19:00'))
  	# render
  end
  it "should have link add to wish list" do
    # expect(rendered).to have_selector('a.add_to_wisht_list')
  end
end