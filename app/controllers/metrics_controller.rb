class MetricsController < ApplicationController
  before_action :set_metric, only: [:edit, :update, :destroy]

  def index
    @metrics = Metric.order(:name)
  end

  def new
    @metric = Metric.new
  end

  def create
    @metric = Metric.new(metric_params)

    if @metric.save
      redirect_to metrics_path, notice: "#{@metric.name} metric created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @metric.update(metric_params)
      redirect_to metrics_path, notice: "#{@metric.name} metric updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @metric.destroy
    redirect_to metrics_path, notice: "Metric deleted."
  end

  private

  def set_metric
    @metric = Metric.find(params[:id])
  end

  def metric_params
    params.require(:metric).permit(:name, :slug, :units, :reference_min, :reference_max, :delta_down_is_good, :daily_loggable)
  end
end
