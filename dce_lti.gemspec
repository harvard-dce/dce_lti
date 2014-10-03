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
  s.summary     = 'An opinionated rails engine to make working with LTI easier'
  s.description = 'An opinionated rails engine to make working with LTI easier'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.rdoc']

  s.add_dependency 'rails', '~> 4.1.4'
  s.add_dependency 'pg'
  s.add_dependency 'ims-lti', '~> 1.1.4'

  s.test_files = Dir['spec/**/*']

  s.add_development_dependency 'rspec-rails', '~> 3.0.2'
  s.add_development_dependency 'capybara', '~> 2.4.3'
  s.add_development_dependency 'capybara-webkit', '~> 1.3.0'
  s.add_development_dependency 'factory_girl_rails', '~> 4.4.1'
  s.add_development_dependency 'byebug', '~> 3.5.1'
  s.add_development_dependency 'shoulda-matchers', '~> 2.7.0'
  s.add_development_dependency 'launchy'
end
