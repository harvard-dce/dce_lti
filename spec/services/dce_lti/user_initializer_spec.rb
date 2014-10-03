module DceLti
  describe UserInitializer do
    it 'finds or creates a user based on the tool provider user_id' do
      user_double = double('user').as_null_object
      fake_oauth_id = 'an_oauth_id'
      allow(tool_provider_double).to receive(:user_id).
        and_return(fake_oauth_id)
      allow(User).to receive(:find_or_create_by).and_return(user_double)

      described_class.find_from(tool_provider_double)

      expect(User).to have_received(:find_or_create_by).
        with(lti_user_id: fake_oauth_id)
      expect(tool_provider_double).to have_received(:user_id)
    end

    it 'adds additional attributes to a user from the tool_provider' do
      user = User.new
      allow(user).to receive_messages(tool_provider_methods)
      allow(User).to receive(:find_or_create_by).and_return(user)

      described_class.find_from(tool_provider_double)

      tool_provider_methods.each do |tool_provider_attribute|
        send_to_tool_provider = tool_provider_attribute.to_s.gsub(/=\Z/,'').to_sym
        expect(user).to have_received(tool_provider_attribute).with(
          tool_provider_attributes[send_to_tool_provider]
        )
      end
    end

    def tool_provider_methods
      tool_provider_attributes.keys.reject do |att|
        att == :user_id
      end.map{|att| "#{att}=".to_sym}
    end

    def  tool_provider_attributes
      {
        user_id: 'an_oauth_id',
        roles: [ 'instructor' ],
        lis_person_contact_email_primary: 'instructor@example.com',
        lis_person_name_family: 'Last Name',
        lis_person_name_full: 'Last Name, First Name',
        lis_person_name_given: 'First Name',
        lis_person_sourcedid: 'sourcedid',
        user_image: 'http://example.com/image.png'
      }
    end

    def tool_provider_double
      @tool_provider_double ||= double(
        'Tool Provider',
        tool_provider_attributes
      )
    end
  end
end
