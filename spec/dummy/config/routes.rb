Rails.application.routes.draw do

  mount DceLti::Engine => "/dce_lti"
end
