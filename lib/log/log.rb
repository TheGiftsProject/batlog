require 'log/config'
require 'log/dispatcher'
require 'log/events'
require 'log/loggable_error'
require 'log/utils'

module Log

  SEVERITIES = {
    :debug  => 0,
    :info   => 1,
    :warn   => 2,
    :error  => 3,
    :fatal  => 4
  }

  def self.config
    @config ||= Log::Config.default
  end

  # This generates the following interface for each severity:
  # log.{severity}(message, context=nil)
  # i.e. log.info("hello", {:subsystem => :user, :action => "user creation"})
  SEVERITIES.each_key do |severity|
    (class << self; self; end).send(:define_method, severity.to_s) do |*args|
      message, ctx = *args
      ctx ||= {}
      ctx = context.merge(ctx)
      self.write(severity, message, ctx)
    end
  end

  def self.assert(condition, message, context = {}, severity=:error, raise_error=nil)
    if condition
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

  def self.context(hash = {})
    Thread.current[:log_context] ||= {}
    Thread.current[:log_context].merge!(hash)
  end

  def self.clear_context
    Thread.current[:log_context] = nil
  end

  private

  def self.write(severity, message, context)
    context = {} if context.nil? # This is different from setting a default. If a user passes nil, it'll be converted to {}.
    context = handle_loggable_error(message, context)
    Dispatcher.dispatch(severity, message, context, Events.all)
  end

  def self.handle_loggable_error(message, context)
    if message.kind_of?(LoggableError)
      context.merge(:error_data => message.data)
    else
      context
    end
  end

  def self.assert_failed(severity, message, context, raise_error)
    write(severity, message, context)
    return if raise_error == false #specific if raise_error is false but config is on
    raise LoggableError.new(message, context) if (raise_error || config.raise_on_failed_asserts)
  end

end
