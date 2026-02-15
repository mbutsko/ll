class Api::MeasurementsController < Api::BaseController
  def create
    entries = normalize_entries(params)
    created = 0
    updated = 0

    entries.each do |entry_params|
      metric = Metric.find_by!(slug: entry_params[:slug])
      date = entry_params[:date] || entry_params[:datetime]&.to_date || Date.current

      measurement = current_user.measurements.find_by(metric: metric, date: date)
      attrs = { value: entry_params[:value], notes: entry_params[:notes] }

      if measurement
        measurement.update!(attrs)
        updated += 1
      else
        current_user.measurements.create!(attrs.merge(metric: metric, date: date))
        created += 1
      end
    end

    render json: { created: created, updated: updated }, status: :created
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def normalize_entries(params)
    if params[:measurements]
      params[:measurements].map { |e| e.permit(:slug, :date, :datetime, :value, :notes) }
    elsif params[:measurement]
      [params[:measurement].permit(:slug, :date, :datetime, :value, :notes)]
    else
      []
    end
  end
end
