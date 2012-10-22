module Log
  class TestLogger

    LogMessage = Struct.new(:severity, :message, :context, :events, :metadata)

    def self.log(severity, message, context, events, metadata)
      logs << LogMessage.new(severity, message, context, events, metadata)
    end

    def self.logs
      @logs ||= reset
    end

    def self.reset
      @logs = []
    end

  end

end