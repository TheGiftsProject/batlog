module Log
  class Config

    attr_accessor :raise_on_log_failure, :raise_on_failed_asserts, :loggers

    def self.default
      new.instance_eval {
        @raise_on_log_failure = false
        @raise_on_failed_asserts = false
        @loggers = default_loggers

        self
      }
    end

    def default_loggers

      loggers = []

      if defined?(::Rails)
        require 'lib/loggers/database_logger'
        require 'lib/loggers/rails_console_logger'
        loggers << DatabaseLogger
        loggers << RailsConsoleLogger
      end

      if defined?(Exceptional)
        require 'lib/loggers/exceptional_logger'
        loggers << ExceptionalLogger
      end

      loggers

    end

  end
end