module DceLti
  describe User do
    context '#lti_user_id' do
      it { should validate_presence_of(:lti_user_id) }
      it { should validate_uniqueness_of(:lti_user_id) }
      it { should ensure_length_of(:lti_user_id).is_at_most(255) }
    end

    context '#roles' do
      it 'keeps an array of roles' do
        roles = %w|foo bar|

        user = build(:user, roles: roles)
        user.save && user.reload

        expect(user.roles).to match_array(roles)
      end

      it 'are case downcased before storing' do
        roles = %w|foo bar BAZ|

        user = build(:user, roles: roles)
        user.save && user.reload

        expect(user.roles).to match_array(['foo','bar', 'baz'])
      end

    end

    context 'has_role?' do
      it 'handles nil elegantly' do
        user = described_class.new

        expect(user).not_to have_role(nil)
      end

      it 'can be queried via predicate methods' do
        user = create(:user, roles: ['foo', 'blee'])

        expect(user).to have_role(:foo)
      end

      it 'downcases a role before querying' do
        user = create(:user, roles: ['foo', 'BLEE'])

        expect(user).to have_role('blee')
      end

      it 'does not care if a role is a string or a symbol' do
        user = create(:user, roles: ['foo', 'BLEE'])

        expect(user).to have_role('blee')
        expect(user).to have_role(:blee)
      end
    end

    it 'stores additional attributes from the consumer' do
      user = described_class.new
      %i|
    lis_person_contact_email_primary
    lis_person_name_family
    lis_person_name_full
    lis_person_name_given
    lis_person_sourcedid
    user_image
      |.each do |attribute|
        expect(user).to respond_to(attribute)
      end
    end
  end
end
