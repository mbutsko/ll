class HomeController < ApplicationController
  def index
    @metrics = Metric.where(daily_loggable: true).order(:id)
    @todays_measurements = current_user.measurements
      .where(date: Date.current)
      .index_by(&:metric_id)
  end
end
