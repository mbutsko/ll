module Api
  class ExerciseLogsController < BaseController
    def create
      exercise = Exercise.find_by(slug: params.dig(:exercise_log, :exercise_slug))
      return render json: { error: "Exercise not found" }, status: :not_found unless exercise

      log = current_user.exercise_logs.new(exercise_log_params)
      log.exercise = exercise
      log.performed_at = params.dig(:exercise_log, :performed_at) || Time.current

      if log.save
        render json: {
          id: log.id,
          exercise_slug: exercise.slug,
          value: log.value,
          weight_lbs: log.weight_lbs,
          performed_at: log.performed_at
        }, status: :created
      else
        render json: { error: log.errors.full_messages.join(", ") }, status: :unprocessable_entity
      end
    end

    private

    def exercise_log_params
      params.require(:exercise_log).permit(:value, :weight_lbs)
    end
  end
end
