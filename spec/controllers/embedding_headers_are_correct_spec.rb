require 'spec_helper'

describe PostsController do
  it 'no X-Frame-Options HTTP header when none is configured' do
    get :index
    expect(response.headers).not_to include('X-Frame-Options')
  end
end
