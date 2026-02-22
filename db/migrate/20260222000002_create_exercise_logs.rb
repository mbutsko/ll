class CreateExerciseLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :exercise_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.references :exercise, null: false, foreign_key: true
      t.decimal :value, precision: 10, scale: 2, null: false
      t.datetime :performed_at, null: false
      t.text :notes
      t.timestamps
    end

    add_index :exercise_logs, [:user_id, :exercise_id]
    add_index :exercise_logs, [:user_id, :performed_at]
  end
end
