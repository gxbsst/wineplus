module Spree
  # This is somewhat contrary to standard REST convention since there is not
  # actually a Checkout object. There's enough distinct logic specific to
  # checkout which has nothing to do with updating an order that this approach
  # is waranted.
  class CheckoutController < Spree::StoreController
    ssl_required

    before_filter :load_order

    before_filter :ensure_order_not_completed
    before_filter :ensure_checkout_allowed
    before_filter :ensure_sufficient_stock_lines
    before_filter :ensure_valid_state

    before_filter :associate_user
    before_filter :check_authorization

    # before_filter :check_authorization
    before_filter :check_registration, :except => [:registration, :update_registration]
    before_filter :alipay_checkout_hook, :only => [:update]

    helper 'spree/users'


    helper 'spree/orders'

    rescue_from Spree::Core::GatewayError, :with => :rescue_from_spree_gateway_error

    # Updates the order and advances to the next state (when possible.)
    def update

      # ADDRESS
      if params[:state] == 'address'
        params[:order][:ship_address_attributes][:user_id] = current_spree_user.id
        current_spree_user.remove_address_current
        if params[:order][:ship_address_attributes][:id].present?
          # @order.update_attributes(object_params)
          ship_address = Spree::Address.find(object_params[:ship_address_attributes][:id])
          ship_address.update_attributes(object_params[:ship_address_attributes])
          @order.ship_address = ship_address
          @order.clone_billing_address
          @order.save!
        else
          @order.build_ship_address(params[:order][:ship_address_attributes])
          @order.clone_billing_address
          @order.save!
        end

        fire_event('spree.checkout.update')
        @order.next
        redirect_to checkout_state_path(@order.state)
      elsif params[:state] == 'delivery'  || params[:state] == 'payment'
        if @order.update_attributes(object_params)

          fire_event('spree.checkout.update')
          return if after_update_attributes

          unless @order.next
            flash[:error] = Spree.t(:payment_processing_failed)
            redirect_to checkout_state_path(@order.state) and return
          end
          if @order.completed?
            session[:order_id] = nil
            flash.notice = Spree.t(:order_processed_successfully)
            flash[:commerce_tracking] = "nothing special"
            redirect_to completion_route
          else
            redirect_to checkout_state_path(@order.state)
          end
        else
          render :edit
        end

      end

      #if @order.update_attributes(object_params)
      #
      #  fire_event('spree.checkout.update')
      #  return if after_update_attributes
      #
      #  unless @order.next
      #    flash[:error] = Spree.t(:payment_processing_failed)
      #    redirect_to checkout_state_path(@order.state) and return
      #  end
      #
      #  if @order.completed?
      #    session[:order_id] = nil
      #    flash.notice = Spree.t(:order_processed_successfully)
      #    flash[:commerce_tracking] = "nothing special"
      #    redirect_to completion_route
      #  else
      #    redirect_to checkout_state_path(@order.state)
      #  end
      #else
      #  render :edit
      #end
    end

    def edit
      @order = current_order(true)
      associate_user
      @ship_add_addressess = current_spree_user.ship_address
      @order.bill_address ||= current_spree_user.current_bill_address
      @order.ship_address ||= current_spree_user.current_ship_address
      before_delivery
      @order.payments.destroy_all if request.put?

      @shipping_methods = @order.shipments.collect(&:shipping_method).compact

    end


    def registration
      @user = Spree::User.new
    end

    def update_registration
      fire_event("spree.user.signup", :order => current_order)
      # hack - temporarily change the state to something other than cart so we can validate the order email address
      current_order.state = current_order.checkout_steps.first
      if current_order.update_attributes(params[:order])
        redirect_to checkout_path
      else
        @user = Spree::User.new
        render 'registration'
      end
    end

    # ALIPAY
    # 支付完毕

    def alipay_done
      payment_return = alipay_return(request.query_string)
      retrieve_order(payment_return.order)
      if @order.present?
        complete_order(@order)
        # render text: 'success'
        redirect_to completion_route
      else
        # redirect_to edit_order_checkout_url(@order, :state => "payment")
      end
    end
    
    # 支付完成通知
    def alipay_notify
      notification = alipay_notifier(request.raw_post)
      order = retrieve_order(notification.out_trade_no)

      if order.present? && notification.acknowledge() && valid_alipay_notification?(notification, order.payment.payment_method.preferred_partner)
        notification.complete? ? order.payment.complete! :  order.payment.failure!
        render text: "success"
      else
        render text: "fail"
      end
    end

    def alipay_checkout_payment
      payment_method =  PaymentMethod.find(params[:payment_method_id])
      @order.payments.create(:amount => @order.total, :payment_method_id => payment_method.id)
    end

    



    private

      def find_or_init_address(params)
        if params[:id].present?
          address = Spree::Address.find(params[:id])
          address.attributes = params[:checkout]
          address
        else
          Spree::Address.new(params[:checkout])
        end
      end

      def ensure_valid_state
        
        unless skip_state_validation?
          if (params[:state] && !@order.has_checkout_step?(params[:state])) ||
             (!params[:state] && !@order.has_checkout_step?(@order.state))
            @order.state = 'cart'
            redirect_to checkout_state_path(@order.checkout_steps.first)
          end
        end
      end

      # Should be overriden if you have areas of your checkout that don't match
      # up to a step within checkout_steps, such as a registration step
      def skip_state_validation?
        false
      end

      def load_order

        @order = current_order
        redirect_to spree.cart_path and return unless @order

        if params[:state]
          redirect_to checkout_state_path(@order.state) if @order.can_go_to_state?(params[:state]) && !skip_state_validation?
          @order.state = params[:state]
        end
        setup_for_current_state
      end

      def ensure_checkout_allowed
        unless @order.checkout_allowed?

          redirect_to spree.cart_path
        end
      end

      def ensure_order_not_completed
        redirect_to spree.cart_path if @order.completed?
      end

      def ensure_sufficient_stock_lines
        if @order.insufficient_stock_lines.present?
          flash[:error] = Spree.t(:inventory_error_flash_for_insufficient_quantity)
          redirect_to spree.cart_path
        end
      end

      # Provides a route to redirect after order completion
      def completion_route
        spree.order_path(@order)
      end

      # For payment step, filter order parameters to produce the expected nested
      # attributes for a single payment and its source, discarding attributes
      # for payment methods other than the one selected
      def object_params
        # respond_to check is necessary due to issue described in #2910
        if @order.has_checkout_step?("payment") && @order.payment?
          if params[:payment_source].present?
            source_params = params.delete(:payment_source)[params[:order][:payments_attributes].first[:payment_method_id].underscore]

            if source_params
              params[:order][:payments_attributes].first[:source_attributes] = source_params
            end
          end

          if (params[:order][:payments_attributes])
            params[:order][:payments_attributes].first[:amount] = @order.total
          end
        end
        params[:order]
      end

      def setup_for_current_state
        method_name = :"before_#{@order.state}"
        send(method_name) if respond_to?(method_name, true)
      end

      def before_address
        @order.bill_address ||= Address.default
        @order.ship_address ||= Address.default
      end

      def before_delivery
        return if params[:order].present?
        packages = @order.shipments.map { |s| s.to_package }
        @differentiator = Spree::Stock::Differentiator.new(@order, packages)
      end

      def before_payment
        packages = @order.shipments.map { |s| s.to_package }
        @differentiator = Spree::Stock::Differentiator.new(@order, packages)
        @differentiator.missing.each do |variant, quantity|
          @order.contents.remove(variant, quantity)
        end
      end

      def rescue_from_spree_gateway_error
        flash[:error] = Spree.t(:spree_gateway_error_flash_for_checkout)
        render :edit
      end

      def check_authorization
        authorize!(:edit, current_order, session[:access_token])
      end

      def after_update_attributes
        coupon_result = Spree::Promo::CouponApplicator.new(@order).apply
        if coupon_result[:coupon_applied?]
          flash[:success] = coupon_result[:success] if coupon_result[:success].present?
          return false
        else
          flash[:error] = coupon_result[:error]
          respond_with(@order) { |format| format.html { render :edit } }
          return true
        end
      end


      def skip_state_validation?
        %w(registration update_registration).include?(params[:action])
      end

      def check_authorization
        authorize!(:edit, current_order, session[:access_token])
      end

      # Introduces a registration step whenever the +registration_step+ preference is true.
      def check_registration
        return unless Spree::Auth::Config[:registration_step]
        return if spree_current_user or current_order.email
        store_location
        redirect_to spree.checkout_registration_path
      end

      # Overrides the equivalent method defined in Spree::Core.  This variation of the method will ensure that users
      # are redirected to the tokenized order url unless authenticated as a registered user.
      def completion_route
        return order_path(@order) if spree_current_user
        spree.token_order_path(@order, @order.token)
      end

      # ALIPAY

      def alipay_checkout_hook
        return unless (params[:state] == "payment")
        return unless params[:order][:payments_attributes].present?
        payment_method = Spree::PaymentMethod.find(params[:order][:payments_attributes].first[:payment_method_id])
        if payment_method.kind_of?(Spree::BillingIntegration::Alipay)

          if @order.update_attributes(object_params) #it would create payments
            if params[:order][:coupon_code] &&  !params[:order][:coupon_code].blank? && @order.coupon_code.present?
              fire_event('spree.checkout.coupon_code_added', :coupon_code => @order.coupon_code)
            end
          end
          alipay_helper_klass = ActiveMerchant::Billing::Integrations::Alipay::Helper
          alipay_helper_klass.send(:remove_const, :KEY) if alipay_helper_klass.const_defined?(:KEY)
          alipay_helper_klass.const_set(:KEY, payment_method.preferred_sign)

          redirect_to aplipay_full_service_url(@order, payment_method)
        end
      end

      def retrieve_order(order_number)
        Spree::Order.find_by_number(order_number)
      end

      def valid_alipay_notification?(notification, account)
        url = "https://mapi.alipay.com/gateway.do?service=notify_verify"
        result = HTTParty.get(url, query: {partner: account, notify_id: notification.notify_id}).body
        result == 'true'
      end

      def aplipay_full_service_url( order, alipay)
        raise ArgumentError, 'require Spree::BillingIntegration::Alipay' unless alipay.is_a? Spree::BillingIntegration::Alipay
        url = ActiveMerchant::Billing::Integrations::Alipay.service_url+'?'
        helper = set_helper(ActiveMerchant::Billing::Integrations::Alipay::Helper.new(order.number, alipay.preferred_partner), order, alipay)
        url << helper.form_fields.collect{ |field, value| "#{field}=#{value}" }.join('&')
        URI.encode url
      end

      def alipay_return(query)
        ActiveMerchant::Billing::Integrations::Alipay::Return.new(query)
      end

      def complete_order(order)
        order.payment.complete!
        order.state='complete'
        order.finalize!
        session[:order_id] = nil
      end

      def alipay_notifier(post)
        ActiveMerchant::Billing::Integrations::Alipay::Notification.new(post)
      end

      def set_helper(helper, order, alipay)
        if alipay.preferred_using_direct_pay_service
          helper.total_fee order.total
          helper.service ActiveMerchant::Billing::Integrations::Alipay::Helper::CREATE_DIRECT_PAY_BY_USER
        else
          helper.price order.item_total
          helper.quantity 1
          helper.logistics :type=> 'EXPRESS', :fee=>order.adjustment_total, :payment=>'BUYER_PAY'
          helper.service ActiveMerchant::Billing::Integrations::Alipay::Helper::TRADE_CREATE_BY_BUYER
        end
        helper.seller :email => alipay.preferred_email
        # helper.notify_url url_for(:only_path => false, :action => 'alipay_notify')
        # helper.return_url url_for(:only_path => false, :action => 'alipay_done')
        helper.notify_url 'http://www.wineplus.me/alipay_checkout/done'
        helper.return_url 'http://www.wineplus.me/alipay_checkout/notify'
        helper.body "order_detail_description"
        helper.charset "utf-8"
        helper.payment_type 1
        helper.subject "#{order.number}"
        helper.sign
        helper
      end

  end
end
