require 'rack-plastic'

module DceLti
  module Middleware
    class CookielessSessions < Rack::Plastic
      def change_nokogiri_doc(doc)
        if no_cookies? || shimmed_cookie?
          doc.css('a').each do |a|
            href = a[:href]

            next unless local_url?(href)
            next if url_has_key_already?(href)

            if href.match(/\?/)
              a[:href] += "&#{session_key_name}=#{session_id}"
            else
              a[:href] += "?#{session_key_name}=#{session_id}"
            end
          end

          doc.css('form').each do |form|
            action = form[:action]
            next unless local_url?(action)
            next if url_has_key_already?(action)

            # For PATCH, PUT, DELETE and POST, which allow
            # params mixed in the action and the form.
            if action.match(/\?/)
              form[:action] += "&#{session_key_name}=#{session_id}"
            else
              form[:action] += "?#{session_key_name}=#{session_id}"
            end

            # For GET, oddly. GET method forms stomp all params encoded
            # in the action
            input_node = Nokogiri::XML::Node.new('input', doc)
            input_node[:type] = 'hidden'
            input_node[:name] = session_key_name
            input_node[:value] = session_id
            form.children.first.add_previous_sibling(
              input_node
            )
          end
        end
        doc
      end

      private

      def shimmed_cookie?
        @p.request.env['HTTP_COOKIE'].to_s.strip.match(/shimmed_cookie/)
      end

      def no_cookies?
        @p.request.env['HTTP_COOKIE'].to_s.strip.empty?
      end

      def local_url?(url)
        ! url.match(/\Ahttps?:\/\/|\/\//i)
      end

      def url_has_key_already?(url)
        url.match(/#{session_key_name}/i)
      end

      def session_key_name
        @session_key_name ||= Rails.application.config.session_options[:key]
      end

      def session
        @p.request.env['rack.session']
      end

      def session_id
        session.id
      end
    end
  end
end
