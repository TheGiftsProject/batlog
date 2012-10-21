require 'lib/log/utils'

class DatabaseLogger
  def self.log(severity, message, context, events, metadata)
    log = nil
    context.merge!({ :metadata => metadata })
    message = Log::Utils.prepare_message(message, true)
    # In order to prevent logs from being deleted by a rollback, we need to create a new database connection (a new transaction doesn't work).
    # The only way to create a new database connection is to open a new thread.
    # Connection must be manually closed at the end of the thread. This only closes the thread's connection, not the main one.
    Thread.new do
      begin
        log = create_log(severity, message, context, events)
      ensure
        ActiveRecord::Base.connection.close # must be done manually on new threads
      end
    end.join # we need the result of this operation before moving on.
    return { :db_log_id => log.id }
  end

  private

  def self.create_log(severity, message, context, events)
    DbLog.create!(:severity => severity.to_s,
                  :message  => message,
                  :context  => context,
                  :events   => events.map{ |event| DbLogEvent.new(event) })
  end
end