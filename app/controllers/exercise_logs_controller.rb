class ExerciseLogsController < ApplicationController
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
    params.require(:exercise_log).permit(:exercise_id, :value)
  end
end
