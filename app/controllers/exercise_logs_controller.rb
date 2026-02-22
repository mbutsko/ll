class ExerciseLogsController < ApplicationController
  def edit
    @exercise_log = current_user.exercise_logs.includes(:exercise).find(params[:id])
  end

  def update
    @exercise_log = current_user.exercise_logs.find(params[:id])
    if @exercise_log.update(exercise_log_params)
      redirect_to root_path, notice: "Exercise entry updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @exercise_log = current_user.exercise_logs.find(params[:id])
    @exercise_log.destroy
    redirect_to root_path, notice: "Exercise entry deleted."
  end

  def create
    @exercise_log = current_user.exercise_logs.new(exercise_log_params)
    @exercise_log.performed_at = Time.current

    if @exercise_log.save
      redirect_to root_path, notice: "Exercise logged."
    else
      redirect_to root_path, alert: "Could not log exercise."
    end
  end

  private

  def exercise_log_params
    params.require(:exercise_log).permit(:exercise_id, :value, :weight_lbs)
  end
end
