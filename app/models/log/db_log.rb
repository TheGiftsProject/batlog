module Log
  class DbLog < ActiveRecord::Base
    self.table_name = :logs

    def context=(hash = {})
      self[:context] = hash.to_json
    end

    def context
      ActiveSupport::JSON.decode(self[:context] || "{}").with_indifferent_access
    end

  end
end