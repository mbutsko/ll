class Exercise < ApplicationRecord
  has_many :exercise_logs, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :exercise_type, inclusion: { in: %w[reps time] }

  def unit_label
    exercise_type == "time" ? "sec" : "reps"
  end
end
