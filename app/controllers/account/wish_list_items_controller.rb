module Account
	
	class WishListItemsController < Spree::StoreController

		ssl_required
		prepend_before_filter :load_user

		def index
			@wish_list = load_wish_list

			if !(@wish_list.owner_by? @user)
				flash[:error] = 'Access Denied.'
				redirect_to account_wish_lists_path
			end

		end

		def show
			redirect_to account_wish_lists_path
		end

		def destroy
			wish_list = load_wish_list

			if wish_list && (wish_list.owner_by? @user)
				wish_list_item = load_wish_list_item
				if wish_list_item 
				  wish_list_item.destroy
					redirect_to account_wish_list_path(wish_list)
				else
					redirect_to account_wish_lists_path
				end
			else
				flash[:error] = 'Access Denied'
				redirect_to account_wish_lists_path	
			end

		end

		def new
			@wish_list_item = WishListItem.new
		end

		def create
			@wish_list = load_wish_list
			if @wish_list.owner_by? @user
				@wish_list_item = WishListItem.new(params[:wish_list_item])
				if @wish_list_item.save
					flash[:notice] = 'Create Successful.'
					redirect_to  account_wish_list_wish_list_items_path(@wish_list)
				else
					flash[:error] = 'Create Failed.'
					render :new
				end
			else
				redirect_to account_wish_lists_path
			end
		end

		private

		def load_wish_list
			WishList.find(params[:wish_list_id])
		end

		def load_wish_list_item
			WishListItem.find(params[:id])
		end

		def load_wish_list_items
			@wish_list = load_wish_list
			if @wish_list
				@wish_list.wish_list_items
			else
				nil
			end
		end

		def load_user
			@user ||= spree_current_user
			authorize! params[:action].to_sym, @user
		end

		def unauthorized
			redirect_to login_path
		end

	end
end
