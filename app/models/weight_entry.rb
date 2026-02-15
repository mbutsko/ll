class WeightEntry < ApplicationRecord
  belongs_to :user

  validates :value, presence: true, numericality: { greater_than: 0 }
  validates :date, presence: true, uniqueness: { scope: :user_id }

  # Returns chart data with rolling averages for a user's weight entries.
  # Fetches extra 30-day buffer before `since` for accurate rolling averages.
  def self.chart_data(user:, since: 90.days.ago.to_date)
    buffer_start = since - 30.days
    entries = where(user: user).where("date >= ?", buffer_start).order(:date).pluck(:date, :value)
    return [] if entries.empty?

    results = []
    entries.each_with_index do |(date, value), i|
      next if date < since

      window_7  = entries.select { |d, _| d > date - 7  && d <= date }.map(&:last)
      window_30 = entries.select { |d, _| d > date - 30 && d <= date }.map(&:last)

      results << {
        date: date.iso8601,
        value: value.to_f,
        avg_7d: window_7.any? ? (window_7.sum / window_7.size).round(1) : nil,
        avg_30d: window_30.any? ? (window_30.sum / window_30.size).round(1) : nil
      }
    end

    results
  end

  # Compares current 7d/30d averages to the prior equivalent periods.
  # Returns hash with deltas (negative = weight loss).
  def self.trend_indicators(user:)
    today = Date.current
    recent_7  = where(user: user).where(date: (today - 6)..today).pluck(:value)
    prior_7   = where(user: user).where(date: (today - 13)..(today - 7)).pluck(:value)
    recent_30 = where(user: user).where(date: (today - 29)..today).pluck(:value)
    prior_30  = where(user: user).where(date: (today - 59)..(today - 30)).pluck(:value)

    {
      avg_7d: recent_7.any? ? (recent_7.sum / recent_7.size).round(1) : nil,
      avg_30d: recent_30.any? ? (recent_30.sum / recent_30.size).round(1) : nil,
      delta_7d: recent_7.any? && prior_7.any? ? ((recent_7.sum / recent_7.size) - (prior_7.sum / prior_7.size)).round(1) : nil,
      delta_30d: recent_30.any? && prior_30.any? ? ((recent_30.sum / recent_30.size) - (prior_30.sum / prior_30.size)).round(1) : nil
    }
  end
end
