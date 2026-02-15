class WeightEntriesController < ApplicationController
  def index
    range = params[:range] || "90d"
    since = case range
            when "30d" then 30.days.ago.to_date
            when "90d" then 90.days.ago.to_date
            when "1y"  then 1.year.ago.to_date
            when "all" then Date.new(2000, 1, 1)
            else 90.days.ago.to_date
            end

    @range = range
    @chart_data = WeightEntry.chart_data(user: current_user, since: since)
    @trends = WeightEntry.trend_indicators(user: current_user)

    respond_to do |format|
      format.html
      format.json { render json: { chart_data: @chart_data, trends: @trends } }
    end
  end

  def create
    @weight_entry = current_user.weight_entries.build(weight_entry_params.merge(date: Date.current))

    if @weight_entry.save
      redirect_to root_path
    else
      redirect_to root_path, alert: @weight_entry.errors.full_messages.to_sentence
    end
  end

  private

  def weight_entry_params
    params.require(:weight_entry).permit(:value)
  end
end
