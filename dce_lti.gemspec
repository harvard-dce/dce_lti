$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'dce_lti/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'dce_lti'
  s.version     = DceLti::VERSION
  s.authors     = ['Dan Collis-Puro']
  s.email       = ['dan@collispuro.net']
  s.homepage    = 'http://www.dce.harvard.edu/'
  s.summary     = 'A rails engine to make working with LTI easier'
  s.description = 'The DceLti engine simplifies integrating LTI authentication for Rails apps via the IMS::LTI gem.'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  s.add_dependency 'rails', '>= 4.1'
  s.add_dependency 'pg', '~> 0.17'
  s.add_dependency 'ims-lti', '~> 1.1'
  s.add_dependency 'rack-plastic', '~> 0.1.3'
  s.add_dependency 'activerecord-session_store', '~> 0.1.1'
  s.add_dependency 'p3p', '~> 1.2.0'

  s.test_files = Dir['spec/**/*']

  s.add_development_dependency 'rspec-rails', '~> 3.0'
  s.add_development_dependency 'capybara', '~> 2.4'
  s.add_development_dependency 'capybara-webkit', '~> 1.3'
  s.add_development_dependency 'factory_girl_rails', '~> 4.4'
  s.add_development_dependency 'pry-byebug', '~> 2.0'
  s.add_development_dependency 'shoulda-matchers', '~> 2.7'
  s.add_development_dependency 'launchy', '~> 2.4'
  s.add_development_dependency 'database_cleaner', '~> 1.3'
end
