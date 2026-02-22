class CreateExercises < ActiveRecord::Migration[8.0]
  def change
    create_table :exercises do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :exercise_type, null: false, default: "reps"
      t.timestamps
    end

    add_index :exercises, :slug, unique: true
  end
end
