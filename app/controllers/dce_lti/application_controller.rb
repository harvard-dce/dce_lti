module DceLti
  class ApplicationController < ActionController::Base
    include ControllerMethods

    protect_from_forgery with: :exception
  end
end
