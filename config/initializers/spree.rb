# Configure Spree Preferences
#
# Note: Initializing preferences available within the Admin will overwrite any changes that were made through the user interface when you restart.
#       If you would like users to be able to update a setting with the Admin it should NOT be set here.
#
# In order to initialize a setting do:
# config.setting_name = 'new value'
Spree.config do |config|
      config.override_actionmailer_config = false
      config.enable_mail_delivery = true
      config.mails_from = "noreply@wineplus.me"
      config.intercept_email = "weston.wei@sidways.com"
      config.shipping_instructions = false
      # config.show_only_complete_orders_by_default = false
      config.track_inventory_levels = true  
end

# Spree.user_class = "Spree::LegacyUser"
Spree.user_class = "Spree::User"
Spree::Config[:display_currency] = false
Spree::Config[:allow_guest_checkout] = false
Spree::Config[:currency] = 'CNY'
Spree::Config.set(:products_per_page => 15) 


ActionMailer::Base.smtp_settings = {
    :address              => "mail.sidways.com",
    :port                 => 25,
    :domain               => 'sidways.com',
    :user_name            => 'patrick_contact@sidways.com',
    :password             => '123456',
    :authentication       => :login,
    :enable_starttls_auto => true
    #:tls => true # ssl
}

# add promotion rule if is vip
Rails.application.config.spree.promotions.rules << Spree::Promotion::Rules::IsVip