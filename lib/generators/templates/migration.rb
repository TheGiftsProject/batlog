class CreateDbLogTable < ActiveRecord::Migration
  def change
    create_table :logs do |t|
      t.string      :severity
      t.text        :message
      t.text        :context
      t.timestamps
    end
  end
end
