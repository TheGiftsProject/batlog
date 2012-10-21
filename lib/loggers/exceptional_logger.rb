require 'lib/log'
require 'exceptional'

class ExceptionalLogger
  class HandleMessageError < StandardError; end

  def self.log(severity, message, context, events, metadata)
    context = context.merge(:severity => severity.to_s, :events => events, :metadata => metadata)
    if message.kind_of?(Exception)
      Exceptional.context(context)
      Exceptional.handle(message)
      Exceptional.clear!
    elsif Log::SEVERITIES[severity] >= Log::SEVERITIES[:error]
      Exceptional.rescue(message, context) do
        raise HandleMessageError.new(message)
      end
    end
  end
end