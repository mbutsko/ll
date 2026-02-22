class CreateFoodLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :food_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.references :food, null: false, foreign_key: true
      t.decimal :value, precision: 10, scale: 2, null: false
      t.string :unit, null: false
      t.datetime :consumed_at, null: false
      t.text :notes
      t.timestamps
    end

    add_index :food_logs, [:user_id, :food_id]
    add_index :food_logs, [:user_id, :consumed_at]
  end
end
