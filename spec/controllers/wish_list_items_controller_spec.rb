require 'spec_helper'

describe Account::WishListItemsController do
	describe "GET index" do
		let(:wish_list) {stub_model(WishList, id: 1)}
		context "user is logged in" do
			let(:user) {create :user}
			before :each do 
				WishList.should_receive(:find).and_return(wish_list)
				wish_list.stub(:user_id).and_return(user.id)
				controller.stub(:spree_current_user => user)
			end
			context "the wish list is owner by user" do
				before :each do 
					wish_list.should_receive(:owner_by?).and_return(true)
				end
				it "render index template" do 
					spree_get :index, wish_list_id: 1
					expect(response).to render_template :index
				end
				it "response the code is 200" do 
					spree_get :index, wish_list_id: 1
					expect(response.code).to eql("200")
				end
			end

			context "the wish list is not owner by user" do
				before :each do 
					wish_list.stub(:owner_by?).with(user).and_return(false)
					wish_list.should_receive(:owner_by?).and_return(false)
				end
				it "redirect_to /account/wish_list" do
				  spree_get :index, wish_list_id: 1
				  expect(flash[:error]).not_to be_nil
				  expect(response).to redirect_to '/account/wish_lists'
				end

			end
		end
		context "user is not logged in" do
			it "redirect_to login path" do
			  spree_get :index, wish_list_id: 1
			  expect(response).to redirect_to '/login'
			end
		end

	end

	describe "GET show" do

		# let!(:wish_list) { stub_model(WishList, id: 1)}
		let_wish_list!
		let(:user) {create :user}
		before(:each) do
			login(user)
		end

	  it "redirect_to /account/wish_lists" do
	    spree_get :show, id: 1
	    expect(response).to redirect_to '/account/wish_lists'
	  end
	end


	describe "DELETE destroy" do
		let_user
		let_wish_list!
		let(:wish_list_item) { stub_model(WishListItem, id: 1)}
		context "user login" do
		  before(:each) do
		   WishList.should_receive(:find).and_return(wish_list)
		   
		   login(user) 
		  end
		  context "is owner" do
		  	before(:each) do
		  		wish_list.should_receive(:owner_by?).and_return(true)  
		  		WishListItem.should_receive(:find).and_return(wish_list_item)
		  		wish_list_item.stub(:destroy)
		  	end

		  	it "redirect_to /account/wish_lists/1" do
		  		wish_list_item.should_receive(:destroy)
		  	  spree_delete :destroy, wish_list_id: 1, id: 1
		  	  expect(response).to redirect_to '/account/wish_lists/1'
		  	end

		  end

		  context "is not owner" do
		    before(:each) do
		    	wish_list.should_receive(:owner_by?).and_return(false)  
		    end
		    it "redirect_to /account/wish_lists" do
		    	# WishList.should_receive(:find).and_return(wish_list)
		    	wish_list_item.should_not_receive(:destroy)
		      spree_delete :destroy, wish_list_id: 1, id: 1
		      expect(response).to redirect_to '/account/wish_lists'
		    end
		  end
		end

		context "user is not logged in" do
		  it "redirect_to /login" do
		    spree_delete :destroy, wish_list_id: 1, id: 1
		    expect(response).to redirect_to '/login'
		  end
		end

	end
 
 describe "GET new" do
 	let_wish_list!
 	context "user is not logged in" do
 		it "redirect_to login" do
 			spree_get :new, id: 1
 			expect(response).to redirect_to '/login'
 		end
 	end
 	 context "user is logged" do 	 	 
 	 	 let_user
 	 	 let(:wish_list_item) { mock_model("WishListItem")}
 	 	 before(:each) do
 	 	   login(user)
 	 	 end
 	   it "send new message to wish list Item" do
 	     WishListItem.should_receive(:new).and_return(wish_list_item)
 	     spree_get :new, id: 1
 	     expect(assigns[:wish_list_item]).to eql(wish_list_item)
 	   end
 	   it "render new template" do
 	     spree_get :new, id: 1
 	     expect(response).to render_template :new
 	   end
 	 end
 end

 describe "POST update" do
 		let_wish_list!

	 	let(:params) do {
	 		"product_id" => "1",
	 		"wish_list_id" => "1"
	 		}
	  end

	  context "user is not logged in" do
	    it "redirect_to login" do
	      spree_post :create, wish_list_item: params
	      expect(response).to redirect_to '/login'
	    end
	  end

	  context "user is login" do
	  	let_user
	  	before(:each) do
	  	  login(user)
	  	end

	  	context "wish_list is owner_by user" do
	  		let!(:wish_list_item) {stub_model(WishListItem)}
	  	  before(:each) do
	  	  	WishList.should_receive(:find).and_return(wish_list)
	  	    wish_list.should_receive(:owner_by?).and_return(true)
	  	    # WishListItem.should_receive(:new).and_return(wish_list_item)
	  	    WishListItem.stub(:new).and_return(wish_list_item)
	  	  end

	  	  it "can mass-assign parameters" do
	  	        WishListItem.unstub(:new)
	  	        spree_post :create, wish_list_item: params
	  	  end

	  	  it "send new message to wish_list_item" do
	  	    WishListItem.should_receive(:new).with(params)
	  	    spree_post :create, wish_list_item: params
	  	  end

	  	  it "send save message to wish_list_item model" do
	  	  	wish_list_item.should_receive(:save)
	  	    spree_post :create, wish_list_item: params 
	  	  end

	  	  context "valid data" do
	  	    before(:each) do
	  	      WishListItem.stub(:save).and_return(true)
	  	    end
	  	    it "redirect_to index page" do
	  	      spree_post :create, wish_list_item: params 
	  	      expect(response).to redirect_to '/account/wish_lists/1/wish_list_items'
	  	    end

	  	    it "assign flash[:notice] not be nil" do
	  	      spree_post :create, wish_list_item: params 
	  	      expect(flash[:notice]).not_to be_nil
	  	    end
	  	  end

	  	  context "invalid data" do
	  	    before(:each) do
	  	      wish_list_item.should_receive(:save).and_return(false)
	  	      spree_post :create, wish_list_item: params
	  	    end
	  	    it "render new template" do
	  	      expect(response).to render_template :new
	  	    end

	  	    it "assign flash[:error] message" do
	  	      expect(flash[:error]).not_to be_nil
	  	    end

	  	    it "assign @wish_list_item variable" do
	  	      expect(assigns[:wish_list_item]).to eql(wish_list_item)
	  	    end
	  	  end

	  	end

	  	context "wish_list is not owner_by user" do
	  	  before(:each) do
	  	    wish_listshould_receive(:owner_by?).and_return(false)
	  	  end
	  	end
	    
	  end

  end
end
