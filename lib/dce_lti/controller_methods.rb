module DceLti
  module ControllerMethods
    def authenticate_via_lti
      redirect_to redirect_after_session_expire unless current_user
    end

    def current_user
      @current_user ||=
        if ENV['FAKE_USER_ID']
          User.find_by(id: ENV['FAKE_USER_ID'])
        else
          User.find_by(id: session[:current_user_id])
        end
    end

    def cookieless_session?
      cookie = env.fetch('HTTP_COOKIE', '')
      cookie.blank? || cookie.match(/shimmed_cookie/)
    end

    def redirect_after_session_expire
      Engine.config.redirect_after_session_expire.call(self)
    end
  end
end
