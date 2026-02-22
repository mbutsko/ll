class CreateLabels < ActiveRecord::Migration[8.0]
  def change
    create_table :labels do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :color, null: false, default: "gray"
      t.timestamps
    end

    add_index :labels, :slug, unique: true
  end
end
