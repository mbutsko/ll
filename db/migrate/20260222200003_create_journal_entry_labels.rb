class CreateJournalEntryLabels < ActiveRecord::Migration[8.0]
  def change
    create_table :journal_entry_labels do |t|
      t.references :journal_entry, null: false, foreign_key: true
      t.references :label, null: false, foreign_key: true
    end

    add_index :journal_entry_labels, [:journal_entry_id, :label_id], unique: true
  end
end
