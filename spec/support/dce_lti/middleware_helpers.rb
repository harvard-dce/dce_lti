module DceLti
  module MiddlewareHelpers
    def session_key_name
      Rails.application.config.session_options[:key]
    end
  end
end
