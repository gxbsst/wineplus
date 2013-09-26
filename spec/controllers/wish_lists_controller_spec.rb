require 'spec_helper'

describe Account::WishListsController do
	describe "GET index" do
	  context "user is logged in" do
	    let(:user) {create :user}
	    before :each do 
	    	controller.stub(:spree_current_user => user)
	    	user.stub(:wish_lists).and_return([])
	    end

	    it "send all message to WishList" do
	    	user.should_receive(:wish_lists)
	    	spree_get :index
	    end

	    it "should render index" do
	    	spree_get :index
	    	expect(response).to render_template :index
	    end

	    it "assigned to @wish_lists variable to the view" do
	    	spree_get :index
	    	expect(assigns[:wish_lists]).to eq([])
	    end
	  end
	 
	  context "user is not logged in" do
	  	  it "redirect_to account_wish_lists_path" do
	  	    spree_get :index
	  	    expect(response).to redirect_to '/login'
	  	  end
	  end

	end

	describe "GET new" do

	 context "when user is logged in" do

	      let!(:wish_list) {mock_model('WishList').as_new_record}
	      let(:user) {create(:user)}
	      before :each do 
	      	# @user = mock_model('User')
	      	# sign_in @user
	      	controller.stub( :spree_current_user => user)
	      end

		  it "should description" do
		    WishList.stub(:new).and_return(wish_list)
		    spree_get :new
		    expect(assigns[:wish_list]).to eq(wish_list)
		  end

		  it "render new template" do 
		  	spree_get :new
		  	expect(response).to render_template :new
		  end
	  end

	  context "user is not logged in" do
	    it "redirect_to login path" do
	    	spree_get :new
	    	expect(response).to redirect_to '/login'
	    end
	  end

	end

	describe "GET show" do

	  let(:wish_list) {stub_model(WishList)}

	  before :each do 
	  	WishList.stub(:find).and_return(wish_list)
	  end

	  context "user is not logged in" do
	    it "redirect_to login path" do
	    	# WishList.should_receive(:find)
	    	spree_get :show, id: 1
	    	expect(response).to redirect_to '/login'
	    end
	  end

	  context "user is login" do

	  	let(:user) { create(:user)}

	  	before :each do 
	  		controller.stub(:spree_current_user => user)
	  	end

	    context "WishList is exist" do

	      it "can access this wish list" do
	      	WishList.should_receive(:find).and_return(wish_list)
	      	wish_list.stub(:owner_by?).and_return(false)
	      	wish_list.should_receive(:owner_by?).and_return(false)
	      	spree_get :show, id: 1
	      	expect(flash[:error]).not_to be_nil
	      	expect(response).to redirect_to '/account/wish_lists'
	      end

	      it "cannot access this wish wish list" do
	      	wish_list.stub(:owner_by?).and_return(true)
	      	spree_get :show, id: 1
	      	expect(response.code).to eq("200")
	      	expect(response).to render_template :show
	      end
	    end

	  end

	end

	describe "edit" do
	  let!(:wish_list) {stub_model(WishList, id: 1)}
	  let(:user) {create :user}
	  before :each do 
	  	WishList.stub(:find).and_return(wish_list)
	  	controller.stub(:spree_current_user => user)
	  end

	  context "when user is the owner" do
	    before(:each) do
	      wish_list.stub(:owner_by?).and_return(true)
	    end

	    it "assign @wish  variable to the view" do
	    	spree_get :edit, id: wish_list.id
	    	expect(assigns[:wish_list]).to eq(wish_list)
	    end

	    it "render edit template" do
	      spree_get :edit, id: wish_list.id
	      expect(response).to render_template :edit
	    end

	  end

	  context "when user is not the owner" do
	    before(:each) do
	      wish_list.stub(:owner_by?).and_return(false)
	    end

	    it "redirect to the denied page" do
	      spree_get :edit, id: wish_list.id
	      expect(response).to redirect_to '/account/wish_lists'  
	    end
	  end
	
	end

	describe "PUT update" do
	 let(:params) do {
	 	"name" => '816'
	 }
	end
	let(:user) {create :user}
	let!(:wish_list) { stub_model(WishList, id: 1)}

	before(:each) do
		controller.stub(:spree_current_user => user)
		WishList.stub(:find).and_return(wish_list)
	end

	 context "user is the owner" do

	 	before(:each) do
	 	  wish_list.stub(:owner_by?).and_return(true)
	 	end

	 	it "send find message" do
	 	  WishList.should_receive(:find).and_return(wish_list)
	 	  wish_list.should_receive(:owner_by?).and_return(true)
	 	  spree_put :update, wish_list: params
	 	end
	   
	 end

	 context "user is not the owner" do
	   
	 end

	end

	describe "POST create" do

		let(:params) do {
			"name" => '815'
		}
		end

	    let(:user) {create :user}

	    let(:wish_list) {stub_model(WishList)}

	    context "user is logged in" do
	      before(:each) do
	        controller.stub(:spree_current_user => user)
	        WishList.stub(:new).and_return(wish_list)
	      end

	      it "create wish list" do
	      	# spree_post "account/wish_lists", wish_list: params
	      	# expect(response.code).to eql('200')
	      end
	    end

	    context "user is not logged in" do
	      
	    end
	end

	describe "DELETE destroy" do
		let(:user) { create :user}
		let!(:wish_list) { stub_model(WishList, id: 1)}
		before(:each) do
		  WishList.should_receive(:find).and_return(wish_list)
		end
		context "logined user" do
		  before(:each) do
		    controller.stub(:spree_current_user => user)
		  end
		  context "user is the owner" do
		  	before(:each) do
		  	  wish_list.should_receive(:owner_by?).and_return(true)
		  	end
		    it "can delete the wish_list" do
		      wish_list.should_receive(:destroy)
		      spree_delete(:destroy, id: 1)
		      expect(response).to redirect_to '/account/wish_lists'
		    end
		  end

		  context "user is not the owner" do
		    before(:each) do
		      wish_list.should_receive(:owner_by?).and_return(false)
		    end
		    it "redirect_to /account/wish_lists" do 
		    	wish_list.should_not_receive(:destroy)
		    	spree_delete :destroy, id: 1
		    	expect(response).to redirect_to '/account/wish_lists'
		    end 
		  end
		end

	end
end
