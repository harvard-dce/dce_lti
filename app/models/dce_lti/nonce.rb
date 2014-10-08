module DceLti
  class Nonce < ActiveRecord::Base
    def self.clean
      delete_all(['created_at < ?', Time.now - 6.hours])
    end

    def self.valid?(nonce)
      begin
        self.create!(nonce: nonce)
        true
      rescue => e
        Rails.logger.warn(%Q|Creating nonce failed: "#{nonce}"|)
        false
      end
    end
  end
end
