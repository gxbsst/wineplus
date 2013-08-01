require 'spec_helper'

describe Spree::CheckoutController do
  describe "get alipay done" do
  	let!(:order) { stub_model(Spree::Order) }
  	let!(:payment) {stub_model(Spree::Payment)}
  	before :each do
  		 controller.class.skip_before_filter :alipay_checkout_hook, :check_registration, :check_authorization, :load_order, :ensure_order_not_completed, :ensure_checkout_allowed, :ensure_sufficient_stock_lines, :ensure_valid_state

  		  warden.set_user Spree::User.find(43)
  		  order.stub(:number).and_return('123')
  		  order.stub(:state).and_return('payment')
  		  order.stub(:payment).and_return(payment)
  		  # order.stub(:payment).and_return(payment)
  		  payment.stub(:order).and_return(order)
  		  # Spree::Order.stub(:create).and_return(order)
  		  controller.instance_variable_set(:@order, order) 
  		  # controller.stub(:@order).and_return(order)

  	end
    it "should description" do

      get 'alipay_done'
       order.should_receive(:payment).and_return(payment)
      # expect(response).to redirect_to '/orders/123'
      expect(order.state).to eq('payment')
      expect(payment.state).to eq('checkout')      
      
    end
  end
end