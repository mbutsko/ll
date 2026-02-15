class Measurement < ApplicationRecord
  include Chartable

  belongs_to :user
  belongs_to :metric

  validates :value, presence: true, numericality: true
  validates :date, presence: true, uniqueness: { scope: [:user_id, :metric_id] }
end
