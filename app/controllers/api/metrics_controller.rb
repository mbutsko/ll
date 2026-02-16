class Api::MetricsController < Api::BaseController
  skip_before_action :authenticate_via_token!, only: [:search]

  def search
    metrics = if params[:q].present?
      Metric.where("name LIKE ?", "%#{Metric.sanitize_sql_like(params[:q])}%")
    else
      Metric.all
    end

    render json: metrics.order(:name).select(:name, :slug).map { |m| { name: m.name, slug: m.slug } }
  end

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
