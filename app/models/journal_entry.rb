class JournalEntry < ApplicationRecord
  belongs_to :user

  has_many :journal_entry_labels, dependent: :destroy
  has_many :labels, through: :journal_entry_labels

  validates :body, presence: true
  validates :recorded_at, presence: true
end
