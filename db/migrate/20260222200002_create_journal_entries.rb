class CreateJournalEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :journal_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.text :body, null: false
      t.datetime :recorded_at, null: false
      t.timestamps
    end

    add_index :journal_entries, [:user_id, :recorded_at]
  end
end
