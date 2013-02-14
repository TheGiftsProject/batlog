class HoneybadgerLogger

  def self.log(severity, message, context, events, metadata)
    context = context.merge(:severity => severity.to_s, :events => events, :metadata => metadata)
    if message.kind_of?(Exception)
      send_to_honeybadger(message, context)
    elsif Log::SEVERITIES[severity] >= Log::SEVERITIES[:error]
      send_to_honeybadger(Exception.new(message), context)
    end
  end

  private

  def self.send_to_honeybadger(exception, context)
    cloned_context = context.clone # we clone the context since we don't want to change it for the next dispatchers
    notify_data = {
        :url => cloned_context[:url],
        :parameters => cloned_context.delete(:params),
        :session_data => cloned_context.delete(:session),
        :context => cloned_context
    }
    Honeybadger.notify(exception, notify_data)
  end

end