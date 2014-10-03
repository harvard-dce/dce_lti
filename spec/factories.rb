FactoryGirl.define do
  factory :user, class: DceLti::User do
    sequence(:lti_user_id) { |n| "user_id-#{n}" }
  end
end
