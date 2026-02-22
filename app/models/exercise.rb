class Exercise < ApplicationRecord
  has_many :exercise_logs, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  def display_summary(log)
    if has_duration && has_distance && log.distance_miles.present? && log.distance_miles > 0
      pace = pace_string(log.value, log.distance_miles)
      "#{name} (#{format_distance(log.distance_miles)}@#{pace})"
    elsif has_duration
      "#{format_duration(log.value)} #{name}"
    elsif has_reps && has_weight && log.weight_lbs.present? && log.weight_lbs > 0
      "#{format_value(log.value)} #{name} (#{format_weight(log.weight_lbs)}#)"
    elsif has_reps
      "#{format_value(log.value)} #{name}"
    else
      name
    end
  end

  private

  def format_value(val)
    val % 1 == 0 ? val.to_i.to_s : val.to_s
  end

  def format_weight(val)
    val % 1 == 0 ? val.to_i.to_s : val.to_s
  end

  def format_duration(seconds)
    seconds = seconds.to_i
    if seconds >= 60
      mins = seconds / 60
      secs = seconds % 60
      "#{mins}:%02d" % secs
    else
      "#{seconds}s"
    end
  end

  def format_distance(miles)
    miles % 1 == 0 ? "#{miles.to_i}mi" : "#{miles}mi"
  end

  def pace_string(seconds, miles)
    pace_minutes = (seconds.to_f / 60) / miles
    pace_whole = pace_minutes.to_i
    pace_secs = ((pace_minutes - pace_whole) * 60).round
    "#{pace_whole}:%02d/mi" % pace_secs
  end
end
