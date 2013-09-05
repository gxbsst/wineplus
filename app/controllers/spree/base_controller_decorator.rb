require_dependency 'spree/base_controller'
Spree::BaseController.class_eval do

  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, with: :render_500
    rescue_from ActionController::RoutingError, with: :render_404
    rescue_from ActionController::UnknownController, with: :render_404
    rescue_from ActionController::UnknownAction, with: :render_404
    rescue_from ActiveRecord::RecordNotFound, with: :render_404
  end

  def render_404(exception)
    #@not_found_path = exception.message
    respond_to do |format|
      format.html { render template: 'errors/error_404', layout: 'spree/layouts/spree_application', status: 404 }
      format.all  { render nothing: true, status: 404 }
    end
  end

   def render_500(exception)
     ExceptionNotifier::Notifier
     .exception_notification(request.env, exception)
     .deliver
     @error = exception
     respond_to do |format|
       format.html { render template: 'errors/error_500', layout: 'spree/layouts/spree_application', status: 500 }
       format.all  { render nothing: true, status: 500}
     end
   end
   


  def spree_login_path
    spree.login_path
  end

  def spree_signup_path
    spree.signup_path
  end

  def spree_logout_path
    spree.destroy_spree_user_session_path
  end

  def spree_current_user
    current_spree_user
  end
end

