class FoodLogsController < ApplicationController
  def edit
    @food_log = current_user.food_logs.includes(:food).find(params[:id])
    @food_log.consumed_at = @food_log.consumed_at.change(sec: 0)
  end

  def update
    @food_log = current_user.food_logs.find(params[:id])
    if @food_log.update(food_log_params)
      redirect_to root_path, notice: "Food entry updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

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
    params.require(:food_log).permit(:food_id, :value, :unit, :consumed_at)
  end
end
