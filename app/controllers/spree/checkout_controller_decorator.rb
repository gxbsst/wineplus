#encoding: utf-8
require_dependency 'spree/checkout_controller'

Spree::CheckoutController.class_eval do
  before_filter :check_authorization
  before_filter :check_registration, :except => [:registration, :update_registration]
  before_filter :alipay_checkout_hook, :only => [:update]

  helper 'spree/users'

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
      complete_order(order)
      redirect_to completion_route
    else
      redirect_to edit_order_checkout_url(@order, :state => "payment")
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
    helper.notify_url 'http://www.sidways.com/alipay_notify'
    helper.return_url 'http://www.sidways.com/alipay_done'
    helper.body "order_detail_description"
    helper.charset "utf-8"
    helper.payment_type 1
    helper.subject "#{order.number}"
    helper.sign
    helper
  end

end
