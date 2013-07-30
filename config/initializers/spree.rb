# Configure Spree Preferences
#
# Note: Initializing preferences available within the Admin will overwrite any changes that were made through the user interface when you restart.
#       If you would like users to be able to update a setting with the Admin it should NOT be set here.
#
# In order to initialize a setting do:
# config.setting_name = 'new value'
Spree.config do |config|
  # Example:
  # Uncomment to override the default site name.
  # config.site_name = "Spree Demo Site"
  # config.mail_host = 'www.wineplus.me'
  # config.mail_domain = 'www.wineplus.me'
  # config.secure_connection_type = 'SSL'
      # preference :secure_connection_type, :string, :default => Core::MailSettings::SECURE_CONNECTION_TYPES[0]
 
      config.override_actionmailer_config = false
      # config.mail_host = 'mail.sidways.com'
      # config.mail_domain = 'sidways.com'
      # config.secure_connection_type = 'SSL'
      # config.mail_auth_type = 'login'
      # config.smtp_username = 'patrick_contact@sidways.com'
      # config.smtp_password = '123456'
      config.enable_mail_delivery = true
      config.mails_from = "weston.wei@sidways.com"
      config.intercept_email = "weston.wei@sidways.com"
    
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