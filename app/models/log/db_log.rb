module Log
  class DbLog < ActiveRecord::Base
    self.table_name = :logs
    attr_accessible :severity, :message, :context

    store :context, :accessors => [:environment]

  end
end