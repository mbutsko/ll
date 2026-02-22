class Food < ApplicationRecord
  UNITS = %w[grams tablespoons cups ounces pieces ml].freeze

  has_many :food_logs, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :default_unit, inclusion: { in: UNITS }
end
