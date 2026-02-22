class Label < ApplicationRecord
  COLORS = %w[gray red orange yellow green blue purple pink].freeze

  has_many :journal_entry_labels, dependent: :destroy
  has_many :journal_entries, through: :journal_entry_labels

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :color, inclusion: { in: COLORS }
end
