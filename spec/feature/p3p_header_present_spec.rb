require 'spec_helper'

feature 'p3p header should be present' do
  scenario 'has a p3p policy header by default' do
    visit '/'

    expect(page.response_headers.keys).to include 'P3P'
  end
end
