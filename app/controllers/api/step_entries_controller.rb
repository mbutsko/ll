class Api::StepEntriesController < Api::BaseController
  def create
    entries = normalize_entries(params)
    created = 0
    updated = 0

    entries.each do |entry_params|
      entry = current_user.step_entries.find_by(date: entry_params[:date])
      if entry
        entry.update!(value: entry_params[:value])
        updated += 1
      else
        current_user.step_entries.create!(date: entry_params[:date], value: entry_params[:value])
        created += 1
      end
    end

    render json: { created: created, updated: updated }, status: :created
  end

  private

  def normalize_entries(params)
    if params[:entries]
      params[:entries].map { |e| e.permit(:date, :value) }
    elsif params[:entry]
      [params[:entry].permit(:date, :value)]
    else
      []
    end
  end
end
