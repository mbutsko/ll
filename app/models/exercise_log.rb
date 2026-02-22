class ExerciseLog < ApplicationRecord
  belongs_to :user
  belongs_to :exercise

  validates :value, presence: true, numericality: true
  validates :performed_at, presence: true
end
