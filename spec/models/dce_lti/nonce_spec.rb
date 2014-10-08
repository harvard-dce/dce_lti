module DceLti
  describe Nonce do
    it { should have_db_index(:nonce).unique(:true) }

    context '.valid?' do
      it 'returns true when a value is unique' do
        expect(described_class.valid?('100')).to be true
      end

      it 'returns false when a value already exists' do
        described_class.create!(nonce: '100')

        expect(described_class.valid?('100')).to be false
      end
    end

    context 'logging' do
      it 'logs about it when a nonce is invalid' do
        allow(Rails.logger).to receive(:warn)
        allow(described_class).to receive(:create!).and_raise

        described_class.valid?('100')

        expect(Rails.logger).to have_received(:warn).with(/Creating nonce failed: "100"/)
      end
    end

    context '.clean' do
      it 'deletes based on the time limit in seconds set in config' do
        Time.freeze do
          allow(described_class).to receive(:delete_all)

          described_class.clean

          expect(described_class).to have_received(:delete_all).with(
            ['created_at < ?', Time.now - 6.hours]
          )
        end
      end
    end
  end
end
