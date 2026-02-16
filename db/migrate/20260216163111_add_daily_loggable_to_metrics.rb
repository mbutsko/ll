class AddDailyLoggableToMetrics < ActiveRecord::Migration[8.1]
  def change
    add_column :metrics, :daily_loggable, :boolean, default: false, null: false
  end
end
