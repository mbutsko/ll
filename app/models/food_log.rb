class FoodLog < ApplicationRecord
  belongs_to :user
  belongs_to :food

  validates :value, presence: true, numericality: { greater_than: 0 }
  validates :consumed_at, presence: true
  validates :unit, presence: true, inclusion: { in: Food::UNITS }
end
