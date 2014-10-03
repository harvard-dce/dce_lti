module DceLti
  describe Configurer do
    it 'accepts a domain, icon, launch_url and title and uses them' do
      domain = 'fooexample.com'
      launch_url = 'http://example.com:4000/lti/launch'
      title = 'A title'
      description = 'A sweet looking tool'
      icon_url = 'http://example.com/icon.png'
      tool_id = '1232'

      configurer = described_class.new(
        domain: domain,
        launch_url: launch_url,
        title: title,
        description: description,
        icon_url: icon_url,
        tool_id: tool_id,
      )

      expect(configurer.to_xml).to include domain
      expect(configurer.to_xml).to include launch_url
      expect(configurer.to_xml).to include title
      expect(configurer.to_xml).to include description
      expect(configurer.to_xml).to include icon_url
      expect(configurer.to_xml).to include tool_id
    end

    context '#to_xml' do
      it 'accepts many or no arguments' do
        configurer = described_class.new

        expect{ configurer.to_xml }.not_to raise_error
        expect{ configurer.to_xml(1,2) }.not_to raise_error
      end
    end
  end
end
