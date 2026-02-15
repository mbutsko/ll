class CreateMetrics < ActiveRecord::Migration[8.0]
  def change
    create_table :metrics do |t|
      t.string :slug, null: false
      t.string :name, null: false
      t.string :units
      t.decimal :reference_min, precision: 10, scale: 2
      t.decimal :reference_max, precision: 10, scale: 2
      t.boolean :delta_down_is_good, default: false, null: false
      t.timestamps
    end

    add_index :metrics, :slug, unique: true
  end
end
