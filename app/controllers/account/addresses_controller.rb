# encoding: utf-8
# module Spree
	# module Account
		class Account::AddressesController < Spree::StoreController

			ssl_required

			prepend_before_filter :authorize_actions, :load_user

			def index
				@addresses = load_addresses
			end

			def show
				@address = load_address
			end

			def new
				@address = Spree::Address.new	
				@address.country = Spree::Country.find_by_iso('CN')
			end

			def edit
				@address = load_address	
				@addresses = load_addresses.where("id != #{@address.id}")
			end

			def create
				@address = Spree::Address.new(params[:address])
				@address.user_id = @user.id
				@address.is_ship_address = true

				clear_default if params[:address][:is_current] == '1'

				if @address.save
					flash[:notice] = 'Create Successfull'
					set_current_address
					redirect_to  account_addresses_path
				else
					render 'new'
				end

			end

			def update
				@address = load_address
				@addresses = load_addresses.where("id != #{@address.id}")

				clear_default if params[:address][:is_current] == '1'

				if @address.update_attributes(params[:address])
					flash[:notice] = 'Update Successfull!'
					set_current_address
					redirect_to  account_addresses_path
				else
					render :action => 'edit'
				end
			end

			def destroy
				@address = load_address

				if @address.destroy
					flash[:notice] = "Delete Successfull!"
					set_current_address
					redirect_to account_addresses_path
				end
			end

			private

			def unauthorized
				redirect_to login_path
			end

			def authorize_actions
				# authorize! params[:action].to_sym, @user
			end

			def load_user
				@user ||= spree_current_user
				authorize! params[:action].to_sym, @user
			end

			def load_address
				load_addresses.try(:find, params[:id])
			end

			def load_addresses
				@user.ship_address.order("is_current DESC, created_at DESC")
			end

			def clear_default
				load_addresses.update_all(:is_current => false)
			end

			def set_current_address
				if !load_addresses.blank? && load_addresses.current.blank?
					load_addresses.first.update_column(:is_current, true)
				end
			end
		end
	# end
# end