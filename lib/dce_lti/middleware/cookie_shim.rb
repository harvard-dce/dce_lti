module DceLti
  module Middleware
    class CookieShim
      def initialize(app)
        @app = app
      end

      def call(env)
        if env['HTTP_COOKIE'].to_s.strip.empty?
          params = parse_query_string(env)
          if params[session_key_name.to_s]
            env['HTTP_COOKIE'] = "#{session_key_name}=#{params[session_key_name.to_s]};shimmed_cookie=1"
          end
        end

        @app.call(env)
      end

      private

      def parse_query_string(env)
        query_string = env['QUERY_STRING']
        params = {}
        query_string.split('&').each do |parameter|
          (key, value) = parameter.split('=')
          params[key] = value
        end
        params
      end

      def session_key_name
        @session_key_name ||= Rails.application.config.session_options[:key]
      end
    end
  end
end
