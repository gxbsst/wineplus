# encoding: utf-8
class Spree::UserMailer < Spree::BaseMailer
  def reset_password_instructions(user)
    @edit_password_reset_url = spree.edit_spree_user_password_url(:reset_password_token => user.reset_password_token)

    mail(:to => user.email, :from => from_address,
        :subject => Spree::Config[:site_name] + ' ' + 
          I18n.t(:subject, :scope => [:devise, :mailer, :reset_password_instructions]))
  end

  def confirmation_instructions(user, bb)
  	mail(:to => user.email, :form => 'no-reply@wineplus.me', :suject => "subject....")
  end

  def reset_password_instructions(user)
    @edit_password_reset_url = spree.edit_spree_user_password_url(:reset_password_token => user.reset_password_token)

    mail(:to => user.email, :from => from_address,
        :subject => "Reset Your Wine⁺ Password")
  end

end
