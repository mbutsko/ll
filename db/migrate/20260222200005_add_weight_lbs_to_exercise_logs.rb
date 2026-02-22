class AddWeightLbsToExerciseLogs < ActiveRecord::Migration[8.1]
  def change
    add_column :exercise_logs, :weight_lbs, :decimal, precision: 6, scale: 1
  end
end
