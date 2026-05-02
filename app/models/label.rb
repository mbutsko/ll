class Label < ApplicationRecord
  COLORS = %w[gray red orange yellow green blue purple pink].freeze

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :color, inclusion: { in: COLORS }
end
