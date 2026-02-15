class HrvEntry < ApplicationRecord
  belongs_to :user

  validates :value, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :date, presence: true, uniqueness: { scope: :user_id }
end
