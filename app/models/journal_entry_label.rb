class JournalEntryLabel < ApplicationRecord
  belongs_to :journal_entry
  belongs_to :label

  validates :label_id, uniqueness: { scope: :journal_entry_id }
end
