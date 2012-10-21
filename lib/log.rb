require_relative 'log/dispatcher'
require_relative 'log/events'
require_relative 'log/loggable_error'
require_relative 'log/utils'

module Log
  SEVERITIES = {
    debug: 0,
    info: 1,
    warn: 2,
    error: 3,
    fatal: 4
  }

  @@raise_on_log_failure = false
  @@raise_on_failed_asserts = false
  @@dispatcher = Dispatcher.new([])

  def self.loggers(loggers)
    self.dispatcher = Dispatcher.new(loggers, @@raise_on_log_failure)
  end

  def self.raise_on_failed_asserts(should_raise)
    @@raise_on_failed_asserts = should_raise
  end

  def self.raise_on_log_failure(should_raise)
    @@raise_on_log_failure = should_raise
    @@dispatcher.raise_on_log_failure = should_raise if (@@dispatcher)
  end

  # This generates the following interface for each severity:
  # log.{severity}(message, context=nil)
  # i.e. log.info("hello", {:subsystem => :user, :action => "user creation"})
  SEVERITIES.each_key do |severity|
    (class << self; self; end).send(:define_method, severity.to_s) do |message, context=nil|
      write(severity, message, context)
    end
  end

  def self.assert(condition, message, context, severity=:error, raise_error=false)
    if (condition)
      return true
    else
      assert_failed(severity, message, context, raise_error)
      return false
    end
  end

  def self.event(name, data={})
    Events.add(name, data)
  end

  def self.clear_events
    Events.reset
  end

  private

  def self.dispatcher=(dispatcher)
    @@dispatcher = dispatcher
  end

  def self.dispatcher
    @@dispatcher
  end

  def self.write(severity, message, context)
    context = {} if (!context) # This is different from setting a default. If a user passes nil, it'll be converted to {}.

    context = handle_loggable_error(message, context)

    dispatcher.dispatch(severity, message, context, Events.all)
  end

  def self.handle_loggable_error(message, context)
    if (message.kind_of?(LoggableError))
      return context.merge({ :error_data => message.data })
    else
      return context
    end
  end

  def self.assert_failed(severity, message, context, raise_error)
    write(severity, message, context)
    raise LoggableError.new(message, context) if (raise_error || @@raise_on_failed_asserts)
  end
end
