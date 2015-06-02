# DceLti - LTI Authentication for Rails apps [![Build Status](https://secure.travis-ci.org/harvard-dce/dce_lti.png?branch=master)](https://travis-ci.org/harvard-dce/dce_lti) [![Code Climate](https://codeclimate.com/github/harvard-dce/dce_lti/badges/gpa.svg)](https://codeclimate.com/github/harvard-dce/dce_lti)

The DceLti engine simplifies integrating LTI authentication for Rails apps via
the [IMS::LTI gem](https://github.com/instructure/ims-lti).

## Prerequisites

* A postgres database
* Rails >= 4.1.x

## Getting started

Add these gems to your gemfile:

    gem 'dce_lti'
    gem 'activerecord-session_store', '~> 0.1.1''

Update (or create) `config/initializers/session_store.rb` and ensure it contains:

    Rails.application.config.session_store :active_record_store, key: '_your_app_session', expire_after: 60.minutes

Where `_your_app_session` is your application's session key.

Bundle, install and then run migrations:

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

That's it! You'll need to configure to fit your use case, but you've got the
basics of LTI authentication (including experimental cookieless sessioning, see
below) working already.

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

`lti.copy_launch_attributes_to_session` is an array of symbols that allows you
to define attributes to copy to the rails session from the tool provider after
a successful launch. See `config/initializers/dce_lti_config.rb` for more info.

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

### p3p headers

On IE11, any security setting "Low" or greater rejects all third party cookies
without p3p headers.

DceLti includes the [p3p](https://rubygems.org/gems/p3p) middleware by default
to insert a basic p3p header for you automatically.  You can configure this
with an initializer, see the p3p docs for examples.

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

## Other

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
`current_user`, rails route helpers and other controller-specific context
through the controller instance passed to it.

### Invalid LTI Sessions

If an LTI session cannot be validated, `dce_lti/sessions/invalid` will be
rendered. You can customize this output by creating a file named
`app/views/dce_lti/sessions/invalid.html.erb`, per the default engine view
resolution behavior.

### Cookieless Sessions - Experimental

If you're running your LTI app on a domain different than your LMS, it will not
work in recent Safari browers.  This is because [Safari blocks third party
cookies set in an iframe by
default](https://support.apple.com/kb/PH19214?locale=en_US). Mozilla has hinted
at implementing this default as well, so the days of setting a cookie in an
iframe and expecting it to work are probably numbered. Thanks, pervasive ad
networks!

There are a few options:

1. Run your LMS and LTI provider on the same domain. This isn't really doable
   if you want to provide a tool useful to multiple consumers on multiple domains,
1. Only provide completely anonymous LTI tools,
1. Build single page javascript-driven apps,
1. Ask your users to enable third-party cookies,
1. Block users when you detect they don't support third-party cookies,
1. Persist the users session by including it in every link and form.

This engine implements the last option by detecting when a browser doesn't
accept cookies and then rewriting outgoing URLs and forms to include a session.

This behavior is disabled by default and requires minimal app-level changes:

1. Edit `config/initializers/dce_lti_config.rb`. Uncomment
   `lti.enable_cookieless_sessions = false` and set it to `true`.
1. You must use database sessions as provided by `activerecord-session_store`,
   which we install by default and you should've already configured.
1. The `redirect_after_successful_auth` path must include the session key and
   id so we can pick it up if cookies aren't available (this is the default as
   well).

Please report bugs to github issues, there are bound to be a few.

If a user supports cookies, we do basically nothing. We don't rewrite forms or
URLs and we use a cookied (and database-backed) session per the usual.

#### How cookieless sessions work

When a request comes in without a cookie but with the session key and ID, then
the `DceLti::Middleware::CookieShim` middleware "shims" it into the Rack
environment and the session information is restored by subsequent middleware.

When we detect that a user doesn't accept third-party cookies, we use
`Rack::Plastic` to rewrite forms and URLs to include the session key and id
from the `redirect_after_successful_auth` redirect.  This happens in the
`DceLti::Middleware::CookielessSessions` middleware.

#### Known issues with cookieless sessions

* Even if your app works with cookieless sessions, other cookie sessioned
  iframe'd apps won't: for instance the youtube javascript iframe API and many
  other third-party javascript apps.
* We only rewrite URLs without a protocol and domain ('/posts/1') to match the
  URLs emitted by rails by default. If you're manually inserting links to your
  application that include the protocol and domain name
  ('http://example.com/posts/1'), the middleware doesn't catch it.  This could
  be fixed to be a bit smarter in the future.
* You will need to ensure that the session key and id tags along for ajax
  requests to your LTI application.

#### Database session cleanup

Run the included `dce_lti:clean_sessions` rake task periodically to remove old
sessions - the default is 7 days, you can modify this with the
`OLDER_THAN_X_DAYS` environment variable, thusly:

    OLDER_THAN_X_DAYS=14 rake dce_lti:clean_sessions

#### Database session hijacking for cookieless sessions

This is an issue, unfortunately. If a malicious user were able to get ahold of
a link in another user's LTI session (when that other user is under a
cookieless session) it'd contain a working session ID and could be exploited.

This can be mitigated several ways:

1. Deliver your LTI application over SSL to protect the transport layer. You
 pretty much need to do this anyway, so this shouldn't be a big deal.
1. Expire your sessions by setting the `expire_after` option in
  `config/initializers/session_store.rb` to a value short enough to not annoy
  your users.

If you set `expire_after` too short, your users will get annoyed. If you set it
too long, the sessions will linger and increase the time the session is
vulnerable. We're looking into other ways of mitigating this as well - PRs
accepted!

### Nonce cleanup

You can clean up lti-related
[nonces](http://en.wikipedia.org/wiki/Cryptographic_nonce) via the
engine-provided `dce_lti:clean_nonces` rake task, which'll remove nonces older
than 6 hours. You should probably run this in a cron job every hour or so. You
can also just invoke `DceLti::Nonce.clean` on your own.

## Contributors

* Dan Collis-Puro - [djcp](https://github.com/djcp)
* Rebecca Nesson - [rebeccanesson](https://github.com/rebeccanesson)

## See Also

* [The Instructure ims-lti gem](https://github.com/instructure/ims-lti)
* [The LTI spec](http://www.imsglobal.org/lti/)
* [Hola Mundo](https://github.com/harvard-dce/hola_mundo), an application using
  most of this this gem, inspired by [cs50's hello world](https://x.cs50.net/hello/)

## License

This project is licensed under the same terms as Rails itself.

## Copyright

2014 President and Fellows of Harvard College
