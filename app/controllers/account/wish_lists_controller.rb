class Account::WishListsController < Spree::StoreController

	ssl_required
	prepend_before_filter :load_user

	def index
		@wish_lists = @user.wish_lists
	end

	def new
	 @wish_list = WishList.new
	end

	def show
	  @wish_list = load_wish_list
	  if @wish_list && !(@wish_list.owner_by? @user)
	  	flash[:error] = 'Access Denied'
	  	redirect_to account_wish_lists_path	  	
	  end
	end

	def edit
	 @wish_list = load_wish_list
	 if !@wish_list.owner_by? @user
	 	redirect_to account_wish_lists_path
	 end
	end

	def create
		
	end

	def update
		@wish_list = load_wish_list
		if @wish_list && (@wish_list.owner_by? @user)
			if @wish_list.update_attributes(params[:wish_list])
				flash[:notice] = 'Update Successful.'
				redirect_to account_wish_lists_path
			else
				flash[:error] = 'Update Failed.'
				render :edit
			end
		else
			flash[:error] = 'Access Denied.'
			redirect_to account_wish_lists_path
		end
	end

	def destroy
		wish_list = load_wish_list
		if wish_list && (wish_list.owner_by? @user)
			wish_list.destroy
		else
			flash[:error] = 'Access Denied.'
		end
		redirect_to account_wish_lists_path
	end

	private

	def load_wish_list
		WishList.find(params[:id])
	end

	def unauthorized
		redirect_to login_path
	end

	def load_user
		@user ||= spree_current_user
		authorize! params[:action].to_sym, @user
	end
end
