class CreateStepEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :step_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.date :date, null: false
      t.integer :value, null: false

      t.timestamps
    end

    add_index :step_entries, [:user_id, :date], unique: true
  end
end
