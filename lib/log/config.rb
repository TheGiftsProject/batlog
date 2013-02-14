require 'loggers/database_logger'
require 'loggers/rails_logger'

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

      loggers << DatabaseLogger
      loggers << RailsLogger

      if defined?(Exceptional)
        require 'loggers/exceptional_logger'
        loggers << ExceptionalLogger
      end

      if defined?(Honeybadger)
        require 'loggers/honeybadger_logger'
      end

      loggers

    end

  end
end