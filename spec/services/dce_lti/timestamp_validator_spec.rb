module DceLti
  describe TimestampValidator do
    it 'returns true for a timestamp that is in range' do
      timestamp = (Time.now - 1.hour).to_i

      expect(described_class.valid?(timestamp)).to be true
    end

    it 'returns false for a timestamp that is not in range' do
      timestamp = (Time.now - 6.hours).to_i

      expect(described_class.valid?(timestamp)).to be false
    end
  end
end
