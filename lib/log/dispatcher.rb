require_relative 'loggable_error'

module Log
  class Dispatcher
    attr_accessor :raise_on_log_failure

    def initialize(loggers, raise_on_log_failure=false)
      Dispatcher.verify_loggers(loggers)
      @loggers = loggers
      @raise_on_log_failure = raise_on_log_failure
    end

    def dispatch(severity, message, context={}, events=[])
      raise ArgumentError.new("context must be Hash") if (!context.kind_of?(Hash))

      failed_loggers = {}
      metadata = {}
      @loggers.each do |logger|
        begin
          result = logger.log(severity, message, context, events, metadata)
          metadata.merge!(result) if (result.kind_of?(Hash))
        rescue => e
          failed_loggers[logger.name] = e
        end
      end

      handle_failed_loggers(failed_loggers)
    end

    private
    def self.verify_loggers(loggers)
      raise ArgumentError.new("Dispatcher requires an array of loggers") if (!loggers.kind_of?(Array))

      loggers.each do |logger|
        raise ArgumentError.new("Logger #{logger.name} doesn't implement self.log") if (!logger.respond_to?(:log))
      end
    end

    def handle_failed_loggers(failed_loggers)
      if (!failed_loggers.empty?)
        logger_errors = failed_loggers.map{ |logger_name, logger_error| { logger_name => logger_error.message } }
        working_loggers = @loggers.reject{ |logger| failed_loggers.keys.include?(logger.name) }
        log_error_dispatcher = Dispatcher.new(working_loggers, @raise_on_log_failure)
        log_error_dispatcher.dispatch(:error, "Loggers failed", { logger_errors: logger_errors })
        raise LoggableError.new("Loggers failed", { logger_errors: logger_errors }) if (@raise_on_log_failure)
      end
    end
  end
end
