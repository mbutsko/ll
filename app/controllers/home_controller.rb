class HomeController < ApplicationController
  def index
    @metrics = Metric.where(daily_loggable: true).order(:id)
    @todays_measurements = current_user.measurements
      .where(date: Date.current)
      .index_by(&:metric_id)

    @todays_exercise_logs = current_user.exercise_logs
      .includes(:exercise)
      .where(performed_at: Date.current.all_day)
      .order(performed_at: :desc)

    last_exercise_logs = current_user.exercise_logs
      .select("exercise_id, value, weight_lbs, distance_miles")
      .where(id: ExerciseLog.select("MAX(id)").where(user_id: current_user.id).group(:exercise_id))
    @last_exercise_values = last_exercise_logs.each_with_object({}) { |log, h| h[log.exercise_id] = log.value }
    @last_exercise_weights = last_exercise_logs.each_with_object({}) { |log, h| h[log.exercise_id] = log.weight_lbs if log.weight_lbs }
    @last_exercise_distances = last_exercise_logs.each_with_object({}) { |log, h| h[log.exercise_id] = log.distance_miles if log.distance_miles }

    @todays_food_logs = current_user.food_logs
      .includes(:food)
      .where(consumed_at: Date.current.all_day)
      .order(consumed_at: :desc)

    @todays_journal_entries = current_user.journal_entries
      .includes(:labels)
      .where(recorded_at: Date.current.all_day)
      .order(recorded_at: :asc)

    @labels = Label.order(:name)
  end
end
