require "csv"

class MeasurementsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :csv_export]

  def index
    @metric = Metric.find_by_slug!(params[:metric_slug])

    default_range = @metric.daily_loggable? ? "90d" : "all"
    range = params[:range] || default_range
    since = case range
            when "30d" then 30.days.ago.to_date
            when "90d" then 90.days.ago.to_date
            when "1y"  then 1.year.ago.to_date
            when "all" then Date.new(2000, 1, 1)
            else 90.days.ago.to_date
            end

    @range = range
    user = current_user || User.first
    @chart_data = Measurement.chart_data(user: user, metric: @metric, since: since)
    @trends = Measurement.trend_indicators(user: user, metric: @metric)

    respond_to do |format|
      format.html
      format.json { render json: { chart_data: @chart_data, trends: @trends } }
    end
  end

  def create
    metric = Metric.find_by_slug!(params[:metric_slug])
    measurement = current_user.measurements.build(
      metric: metric,
      date: Date.current,
      value: params[:measurement][:value]
    )

    if measurement.save
      redirect_to root_path
    else
      redirect_to root_path, alert: measurement.errors.full_messages.to_sentence
    end
  end

  def new
    @measurement = current_user.measurements.build(date: Date.current)
    if params[:metric_slug].present?
      @measurement.metric = Metric.find_by_slug(params[:metric_slug])
    end
    @metrics = Metric.order(:name)
  end

  def edit
    @measurement = current_user.measurements.find(params[:id])
    @metrics = Metric.order(:name)
  end

  def full_create
    @measurement = current_user.measurements.build(measurement_params)

    if @measurement.save
      redirect_to root_path
    else
      @metrics = Metric.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @measurement = current_user.measurements.find(params[:id])

    if @measurement.update(measurement_params)
      redirect_to root_path
    else
      @metrics = Metric.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def csv_export
    user = current_user || User.first
    metrics = Metric.order(:name)
    measurements = Measurement.where(user: user)
      .joins(:metric)
      .select("measurements.date, measurements.value, metrics.name as metric_name")

    if measurements.empty?
      redirect_to root_path, notice: "No data to export."
      return
    end

    lookup = measurements.each_with_object({}) do |m, hash|
      hash[[m.date, m.metric_name]] = m.value
    end

    min_date = Measurement.where(user: user).minimum(:date)
    max_date = Measurement.where(user: user).maximum(:date)
    metric_names = metrics.pluck(:name)

    csv_data = CSV.generate do |csv|
      csv << ["date"] + metric_names
      (min_date..max_date).each do |date|
        csv << [date.iso8601] + metric_names.map { |name| lookup[[date, name]] }
      end
    end

    send_data csv_data,
      filename: "measurements-#{min_date}-to-#{max_date}.csv",
      type: "text/csv",
      disposition: "attachment"
  end

  private

  def measurement_params
    params.require(:measurement).permit(:metric_id, :date, :value, :notes)
  end
end
