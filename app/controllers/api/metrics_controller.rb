class Api::MetricsController < Api::BaseController
  def create
    metric = Metric.find_or_initialize_by(slug: metric_params[:slug])
    metric.assign_attributes(metric_params)

    if metric.save
      render json: { metric: metric.slice(:id, :slug, :name, :units, :reference_min, :reference_max, :delta_down_is_good) },
             status: metric.previously_new_record? ? :created : :ok
    else
      render json: { errors: metric.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def metric_params
    params.require(:metric).permit(:slug, :name, :units, :reference_min, :reference_max, :delta_down_is_good)
  end
end
