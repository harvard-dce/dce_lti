module DceLti
  FactoryGirl.define do
    factory :user, class: User do
      sequence(:lti_user_id) { |n| "user_id-#{n}" }
    end
  end
end
