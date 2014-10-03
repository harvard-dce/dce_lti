Rails.application.config.lti_provider_configs = {
  title: (ENV['LTI_PROVIDER_TITLE'] || 'DCE LTI Provider'),
  description: (ENV['LTI_PROVIDER_DESCRIPTION'] || 'A description of this'),
  icon_url: (ENV['LTI_PROVIDER_ICON_URL'] || '//example.com/icon.png'),
  tool_id: (ENV['LTI_PROVIDER_TOOL_ID'] || '1234567890'),
  consumer_secret: (ENV['LTI_CONSUMER_SECRET'] || 'consumer_secret'),
  redirect_after_successful_auth: ->{ Rails.application.routes.url_helpers.root_path },
}
