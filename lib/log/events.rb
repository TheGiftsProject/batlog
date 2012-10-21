module Log
  module Events
    EVENTS_KEY = :log_events

    def self.add(name, data)
      Thread.current[EVENTS_KEY] = all.push({ name: name, data: data })
      return self
    end

    def self.reset
      Thread.current[EVENTS_KEY] = []
      return self
    end

    def self.all
      (Thread.current[EVENTS_KEY] || []).dup
    end
  end
end
