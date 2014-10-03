class PostsController < ApplicationController
  before_filter :authenticate_via_lti
  def index
    render text: 'Foo'
  end
end
