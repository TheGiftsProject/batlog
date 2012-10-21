require 'log/loggable_error'

module Log
  class Dispatcher
    attr_accessor :raise_on_log_failure

    def initialize
      Dispatcher.verify_loggers(config.loggers)
    end


    def dispatch(severity, message, context={}, events=[])
      raise ArgumentError.new("context must be Hash") unless context.kind_of?(Hash)

      failed_loggers = {}
      metadata = {}
      config.loggers.each do |logger|
        begin
          single_dispatch(logger, severity, message, context, events, metadata)
        rescue => e
          failed_loggers[logger.name] = e
        end
      end

      handle_failed_loggers(failed_loggers)
    end

    private

    def single_dispatch(logger, severity, message, context, events, metadata)
      result = logger.log(severity, message, context, events, metadata)
      metadata.merge!(result) if (result.kind_of?(Hash))
    end

    def config
      Log.config
    end

    def self.verify_loggers(loggers)
      raise ArgumentError.new("Dispatcher requires an array of loggers") if (!loggers.kind_of?(Array))

      loggers.each do |logger|
        raise ArgumentError.new("Logger #{logger.name} doesn't implement self.log") if (!logger.respond_to?(:log))
      end
    end

    def handle_failed_loggers(failed_loggers)
      unless failed_loggers.empty?
        logger_errors = failed_loggers.map{ |logger_name, logger_error| { logger_name => logger_error.message } }
        redispatch_failed_loggers(failed_loggers, logger_errors)
        raise LoggableError.new("Loggers failed", { :logger_errors => logger_errors }) if config.raise_on_log_failure
      end
    end

    def redispatch_failed_loggers(failed_loggers, logger_errors)
      working_loggers = config.loggers.reject{ |logger| failed_loggers.keys.include?(logger.name) }
      metadata = {}
      working_loggers.each do |logger|
        begin
          single_dispatch(logger, :error, "Loggers failed", {:logger_errors => logger_errors}, [], metadata)
        rescue => e
          e
        end
      end
    end

  end
end
