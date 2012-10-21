module Log
  class LoggableError < StandardError
    attr_accessor :data

    def initialize(message=nil, data=nil)
      super(message)
      @data = data
    end
  end
end
