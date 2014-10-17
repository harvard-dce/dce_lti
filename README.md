# DceLti - LTI Authentication for Rails apps

The DceLti engine simplifies integrating LTI authentication for Rails apps via
the [IMS::LTI gem](https://github.com/instructure/ims-lti).

## Prerequisites

* A postgres database
* Rails > 4.1.x

## Getting started

Add this engine to your gemfile:

    gem 'dce_lti'

Install it and run migrations:

    bundle
    rake dce_lti:install
    rake db:migrate

Mount the engine in 'config/routes.rb'

    mount DceLti::Engine => "/lti"

Once mounted, you can use the engine-provided methods `authenticate_via_lti`
and `current_user`. Use `authenticate_via_lti` as a `before_filter` to ensure
you have a valid LTI-provided user in `current_user`, thusly:

    class VideosController < ApplicationController
      before_filter :authenticate_via_lti

      def show
         @post = current_user.posts.where(id: params[:id])
      end
    end

## Configuration

The generated config looks something like (commented defaults omitted):

    DceLti::Engine.setup do |lti|
      lti.consumer_secret = (ENV['LTI_CONSUMER_SECRET'] || 'consumer_secret')
      lti.consumer_key = (ENV['LTI_CONSUMER_KEY'] || 'consumer_key')
      lti.tool_config_extensions = ->(controller, tool_config) do
        tool_config.extend ::IMS::LTI::Extensions::Canvas::ToolConfig
        tool_config.canvas_domain!(controller.request.host)
        tool_config.canvas_privacy_public!
      end
    end

### Basic attributes

Most basic attributes are configured via ENV. See the generated
`config/initializers/dce_lti_config.rb` file.

### X-Frame Options

We install a config file that removes `X-Frame-Options` by default to allow
your application to be embedded in an `iframe`. Feel free to edit this file if
you'd like to lock down `iframe` policies.

### Consumer key and secret configuration

If you're building an LTI app that will only ever provide a tool to one
consumer, then getting the key and secret from ENV is OK. However, in all
likelihood you'll want your tool to work for any approved consumer and will
need something more flexible.

With that in mind, `consumer_key` and `consumer_secret` can be lambdas and
receive the `launch_params` as sent by the consumer. These launch parameters
include the `consumer_key` and other attributes to help you identify a consumer
uniquely - most likely `context_id` or `tool_consumer_instance_guid`. Example:

    DceLti::Engine.setup do |lti|
      lti.consumer_secret = ->(launch_params) {
        Consumer.find_by(context_id: launch_params[:context_id]).consumer_secret
      }
      lti.consumer_key = ->(launch_params) {
        Consumer.find_by(context_id: launch_params[:context_id]).consumer_key
      }
    }

### Customizing the Tool Provider XML configuration

The tool config instance (provided by
[IMS::LTI::ToolConfig](https://github.com/instructure/ims-lti/blob/master/lib/ims/lti/tool_config.rb))
can be configured directly via the `tool_config_extensions` lambda. This allows
you to set LMS-specific config extensions. A common example for the Canvas LMS
is created by default in the generated configs.

The `tool_config_extensions` lambda runs before the xml is generated and gets
two parameters:

* controller - An instance of DceLti::ConfigsController
* tool_config - An instance of IMS::LTI::ToolConfig

See
[IMS::LTI::Extensions::Canvas::ToolConfig](https://github.com/instructure/ims-lti/blob/master/lib/ims/lti/extensions/canvas.rb)
and other classes/modules under the IMS::LTI::Extensions hierarchy for further
options.

## Notes

The `DceLti` provided controllers inherit from `ApplicationController` as
defined in your application.

### Consumer context info

For successful launches, the controller `session` hash will contain:

* `:context_id`
* `:context_label`
* `:context_title`
* `:resource_link_id`
* `:resource_link_title`
* `:tool_consumer_instance_guid`

These values come from the LTI values posted by the consumer.

### After a successful launch

By default, a successful launch will redirect to your application's
`root_path`. This is configured via `redirect_after_successful_auth` which is
evaluated in engine controller context. This method should have access to
`current_user`, rails route helpers and other controller-specific context.

### Invalid LTI Sessions

If an LTI session cannot be validated, `dce_lti/sessions/invalid` will be
rendered. You can customize this output by creating a file named
`app/views/dce_lti/sessions/invalid.html.erb`, per the default engine view
resolution behavior.

### Nonce cleanup

You can clean up lti-related
[nonces](http://en.wikipedia.org/wiki/Cryptographic_nonce) via the
engine-provided `dce_lti:clean_nonces` rake task, which'll remove nonces older
than 6 hours. You should probably run this in a cron job every hour or so. You
can also just invoke `DceLti::Nonce.clean` on your own.

## Contributors

* Dan Collis-Puro - @djcp

## License

This project is licensed under the same terms as Rails itself.

## Copyright

2014 President and Fellows of Harvard College
