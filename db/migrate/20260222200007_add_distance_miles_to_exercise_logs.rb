class AddDistanceMilesToExerciseLogs < ActiveRecord::Migration[8.1]
  def change
    add_column :exercise_logs, :distance_miles, :decimal, precision: 6, scale: 2
  end
end
