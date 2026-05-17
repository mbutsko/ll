class DropFoodTables < ActiveRecord::Migration[8.1]
  def change
    drop_table :food_logs
    drop_table :foods
  end
end
