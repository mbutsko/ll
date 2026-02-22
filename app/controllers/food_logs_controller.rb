class FoodLogsController < ApplicationController
  def destroy
    @food_log = current_user.food_logs.find(params[:id])
    @food_log.destroy
    redirect_to root_path, notice: "Food entry deleted."
  end

  def create
    @food_log = current_user.food_logs.new(food_log_params)
    @food_log.consumed_at = Time.current

    if @food_log.save
      redirect_to root_path, notice: "Food logged."
    else
      redirect_to root_path, alert: "Could not log food."
    end
  end

  private

  def food_log_params
    params.require(:food_log).permit(:food_id, :value, :unit)
  end
end
