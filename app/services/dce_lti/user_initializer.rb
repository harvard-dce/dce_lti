module DceLti
  class UserInitializer
    TOOL_PROVIDER_ATTRIBUTES = %i|
    roles
    lis_person_contact_email_primary
    lis_person_name_family
    lis_person_name_full
    lis_person_name_given
    lis_person_sourcedid
    user_image
    |

    def self.find_from(tool_provider)
      User.find_or_create_by(lti_user_id: tool_provider.user_id).tap do |user|
        TOOL_PROVIDER_ATTRIBUTES.each do |attribute|
          user.send("#{attribute}=", tool_provider.send(attribute))
        end
        user.save
      end
    end
  end
end
