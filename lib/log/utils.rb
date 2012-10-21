module Log
  class Utils
    def self.pretty_print_exception(exception)
      raise ArgumentError.new("must pass exception") if (!exception.kind_of? Exception)

      # Code taken from C:\Ruby192\lib\ruby\gems\1.9.1\gems\actionpack-3.0.3\lib\action_dispatch\middleware\show_exceptions.rb
      message = "\n#{exception.class} (#{exception.message}):\n"
      message << exception.annoted_source_code.to_s if exception.respond_to?(:annoted_source_code)
      message << "  " << (defined?(Rails) && Rails.respond_to?(:backtrace_cleaner) && exception.backtrace ?
            Rails.backtrace_cleaner.clean(exception.backtrace) :
            exception.backtrace).try(:join, "\n  ").to_s

      return message
    end

    def self.prepare_message(message, simple=false)
      if message.kind_of? Exception
        if (simple)
          return message.message
        else
          return pretty_print_exception(message)
        end
      end

      return message.to_s
    end
  end
end
