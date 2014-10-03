module DceLti
  class User < ActiveRecord::Base
    validates :lti_user_id,
      uniqueness: true,
      length: { maximum: 255 },
      presence: true

    def roles=(roles)
      super roles.map{|role| role.downcase}
    end

    def has_role?(role)
      roles.include?(role.to_s.downcase)
    end
  end
end
