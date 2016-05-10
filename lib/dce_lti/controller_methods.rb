module DceLti
  module ControllerMethods
    def authenticate_via_lti
      if ! current_user
        redirect_to Engine.routes.url_helpers.invalid_sessions_path
      end
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
  end
end
