module DceLti
  module Middleware
    describe CookielessSessions do
      include MiddlewareHelpers
      context 'no cookies or a shimmed cookie' do
        it 'puts in a session in urls and forms' do
          app = lambda { |env| [200, {'Content-Type' => 'text/html'}, [html_output]] }
          session_double = double('session')
          session_id = '100'
          allow(session_double).to receive(:id).and_return(session_id)

          environments = [
            { 'rack.session' => session_double },
            {
              'rack.session' => session_double,
              'HTTP_COOKIE' => %Q|#{session_key_name}=#{session_id};shimmed_cookie=1|
            }
          ]

          environments.each do |env|
            middleware = described_class.new(app)
            result = middleware.call(env)
            modified_content = result[2][0]

            expect(modified_content).to include %Q|href="/foobar/?#{session_key_name}=#{session_id}|

            expect(modified_content).to include %Q|<input type="hidden" name="#{session_key_name}" value="#{session_id}">|
          end
        end
      end

      context 'a regular cookied session' do
        it 'does not put a session in urls and forms' do
          app = lambda { |env| [200, {'Content-Type' => 'text/html'}, [html_output]] }
          session_double = double('session')
          session_id = '100'
          allow(session_double).to receive(:id).and_return(session_id)

          env = {
            'rack.session' => session_double,
            'HTTP_COOKIE' => %Q|#{session_key_name}=#{session_id}|
          }

          middleware = described_class.new(app)
          result = middleware.call(env)
          modified_content = result[2][0]

          expect(modified_content).not_to include %Q|#{session_key_name}|
          expect(modified_content).to eq html_output
        end
      end

      def html_output
        %Q|<!DOCTYPE html>
<html>
  <head>
  <meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">
  <title>A title</title>
</head>
  <body>
    <a href="/foobar/" id="a_link">A link</a>
    <form action="/form/action">
    </form>
  </body>
</html>
|
      end

    end
  end
end
