# DceLti

The DceLti engine simplifies LTI authentication and configuration via the
IMS::LTI gem.

## Getting started

Add this engine to your gemfile:

    gem 'dce_lti'

Install it and run migrations:

    bundle
    rake dce_lti:install
    rake db:migrate

See the generated `config/initializers/lti_configs.rb` file for the relevant
environment variables used to configure this engine.  This also installs a
config file that removes `X-Frame-Options` by default to allow this application
to be embedded in an `iframe`.

Mount the engine in 'config/routes.rb'

    mount DceLti::Engine => "/lti"

Include the authentication helper methods in your controllers:

    class ApplicationController < ActionController::Base
      include DceLti::ControllerMethods
    end

You can now use the `authenticate_via_lti` before_filter to ensure you have a
valid LTI-provided user in `current_user`, thusly:

    class VideosController < ApplicationController
      before_filter :authenticate_via_lti

      def show
         @post = current_user.posts.where(id: params[:id])
      end
    end

The default rails `session` hash will also contain `:resource_link_id`,
`:resource_link_title` and `:context_id` values extracted from the LTI
information for authenticated routes.

By default, a successful launch will be redirected to your application's
`root_path`. See below about customizing `redirect_after_successful_auth` if you
want to change this behavior or don't have a `root_path` defined.

If an LTI session cannot be validated, `dce_lti/sessions/invalid` will be
rendered. You can customize this output by creating a file named
`app/views/dce_lti/sessions/invalid.html.erb`, per the normal engine view
resolution behavior.

## Configuration

The generated config file should look something like:

    Rails.application.config.lti_provider_configs = {
      title: (ENV['LTI_PROVIDER_TITLE'] || 'DCE LTI Provider'),
      description: (ENV['LTI_PROVIDER_DESCRIPTION'] || 'A description of this'),
      icon_url: (ENV['LTI_PROVIDER_ICON_URL'] || '//example.com/icon.png'),
      tool_id: (ENV['LTI_PROVIDER_TOOL_ID'] || '1234567890'),
      consumer_secret: (ENV['LTI_CONSUMER_SECRET'] || 'consumer_secret'),
      redirect_after_successful_auth: ->{ Rails.application.routes.url_helpers.root_path },
    }

The `DceLti` provided controllers inherit from `ApplicationController` as
defined in your application.

`redirect_after_successful_auth` is evaluated in engine controller context, so
you should have access to `current_user`, rails route helpers and other
controller-specific context.  You should be sure to create a `root_path` route.

You can also customize `launch_url`, which is POSTed to by the tool consumer
and expected to verify the LTI oauth2 signatures. Generally you wouldn't do
this, as you'd be left to implement signature validation and other messy
LTI-specific bits.

## Contributors

* Dan Collis-Puro - @djcp

## License

This project is licensed under the same terms as Rails itself.

## Copyright

2014 President and Fellows of Harvard College
