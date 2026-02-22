class AddCapabilityFlagsToExercises < ActiveRecord::Migration[8.1]
  def up
    add_column :exercises, :has_reps, :boolean, default: false, null: false
    add_column :exercises, :has_weight, :boolean, default: false, null: false
    add_column :exercises, :has_duration, :boolean, default: false, null: false
    add_column :exercises, :has_distance, :boolean, default: false, null: false

    Exercise.reset_column_information
    Exercise.where(exercise_type: "reps").update_all(has_reps: true)
    Exercise.where(exercise_type: "time").update_all(has_duration: true)
  end

  def down
    remove_column :exercises, :has_reps
    remove_column :exercises, :has_weight
    remove_column :exercises, :has_duration
    remove_column :exercises, :has_distance
  end
end
