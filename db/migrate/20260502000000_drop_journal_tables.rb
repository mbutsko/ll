class DropJournalTables < ActiveRecord::Migration[7.2]
  def change
    drop_table :journal_entry_labels
    drop_table :journal_entries
  end
end
