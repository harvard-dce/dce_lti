# This ensures the application can be displayed in an iframe
Rails.application.config.x_frame_options = (ENV['X_Frame_Options'])

if Rails.application.config.x_frame_options.present?
    Rails.application.config.action_dispatch.default_headers['X-Frame-Options'] =\
      Rails.application.config.x_frame_options
else
    Rails.application.config.action_dispatch.default_headers.delete('X-Frame-Options')
end
