class CreateMeasurements < ActiveRecord::Migration[8.0]
  def change
    create_table :measurements do |t|
      t.references :user, null: false, foreign_key: true
      t.references :metric, null: false, foreign_key: true
      t.date :date, null: false
      t.decimal :value, precision: 10, scale: 2, null: false
      t.text :notes
      t.timestamps
    end

    add_index :measurements, [:user_id, :metric_id, :date], unique: true
  end
end
