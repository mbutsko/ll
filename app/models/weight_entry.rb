class WeightEntry < ApplicationRecord
  belongs_to :user

  validates :value, presence: true, numericality: { greater_than: 0 }
  validates :date, presence: true, uniqueness: { scope: :user_id }
end
