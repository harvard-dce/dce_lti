namespace :dce_lti do

  def install_file(config_file)
    if ! File.exists?(config_file)
      puts %Q|Copied configuration #{config_file} from dce_lti|
      FileUtils.copy("#{DceLti::Engine.root}/spec/dummy/#{config_file}", config_file)
    end
  end

  desc "Install the DceLti engine into your application"
  task :install do
    install_file 'config/initializers/dce_lti_config.rb'
    install_file 'config/initializers/x_frame_options.rb'

    Rake::Task["dce_lti:install:migrations"].invoke

    puts %Q|
Base migrations and config files have been installed, please see above.

Be sure to mount this engine in your config/routes.rb file, thusly:

    mount DceLti::Engine => "/lti"

Please see the README for more information about configuration and what this
engine provides.

    |
  end

  desc 'Clean up old nonces'
  task clean_nonces: :environment do
    DceLti::Nonce.clean
  end
end
