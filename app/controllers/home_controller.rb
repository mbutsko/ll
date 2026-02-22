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

    @todays_food_logs = current_user.food_logs
      .includes(:food)
      .where(consumed_at: Date.current.all_day)
      .order(consumed_at: :desc)
  end
end
