class AddDefaultServingToFoods < ActiveRecord::Migration[8.0]
  def change
    add_column :foods, :default_serving, :decimal, precision: 10, scale: 2
  end
end
