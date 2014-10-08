module DceLti
  class TimestampValidator
    def self.valid?(timestamp)
      Time.at(timestamp.to_i) >= (Time.now - 3.hours)
    end
  end
end
