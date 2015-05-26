module DceLti
  module RedirectToHelper
    def redirect_to(options, response_status = {})
      session_key_name = Rails.application.config.session_options[:key]
      if request.env.fetch('HTTP_COOKIE', '').match(/shimmed_cookie/) &&
        (::DceLti::Engine.config.enable_cookieless_sessions)
        case options
        when Hash
          options.merge!(session_key_name => session.id)
        when String
          if options.match(/\?/)
            unless options.match(/#{session_key_name}/)
              options += %Q|&#{session_key_name}=#{session.id}|
            end
          else
            unless options.match(/#{session_key_name}/)
              options += %Q|?#{session_key_name}=#{session.id}|
            end
          end
        end
      end
      super(options, response_status)
    end
  end
end
