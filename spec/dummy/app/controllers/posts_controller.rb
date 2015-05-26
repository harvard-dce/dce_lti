class PostsController < ApplicationController
  before_filter :authenticate_via_lti
  def index
    render text: 'Foo'
  end

  def redirect_with_response_status
    redirect_to root_path, status: :moved_permanently
  end
end
