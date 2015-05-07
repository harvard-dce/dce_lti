module DceLti
  module Middleware
    describe CookieShim do
      include MiddlewareHelpers

      context 'without a cookie' do
        it 'shims the session into the cookie if there is a session' do
          app_double = double('App stand-in')
          allow(app_double).to receive(:call)
          env = {
            'QUERY_STRING' => %Q|#{session_key_name}=1000|,
          }

          middleware = described_class.new(app_double)
          middleware.call(env)

          expect(app_double).to have_received(:call).with(
            hash_including('HTTP_COOKIE' => %Q|#{session_key_name}=1000;shimmed_cookie=1|)
          )
        end

        it 'does not shim in the cookie if the session is not there' do
          app_double = double('App stand-in')
          allow(app_double).to receive(:call)
          env = {
            'QUERY_STRING' => ''
          }
          middleware = described_class.new(app_double)
          middleware.call(env)

          expect(app_double).to have_received(:call).with(
            hash_not_including('HTTP_COOKIE')
          )
        end
      end

      context 'with a cookie' do
        it 'leaves the cookie untouched' do
          app_double = double('App stand-in')
          allow(app_double).to receive(:call)
          env = {
            'QUERY_STRING' => 'query_string=100',
            'HTTP_COOKIE' => 'cookie=beep'
          }
          middleware = described_class.new(app_double)
          middleware.call(env)

          expect(app_double).to have_received(:call).with(
            hash_including(
              'HTTP_COOKIE' => 'cookie=beep',
              'QUERY_STRING' => 'query_string=100'
            )
          )
        end
      end
    end
  end
end
