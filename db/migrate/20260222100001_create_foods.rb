class CreateFoods < ActiveRecord::Migration[8.0]
  def change
    create_table :foods do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :default_unit, null: false, default: "grams"
      t.timestamps
    end

    add_index :foods, :slug, unique: true
  end
end
