class Api::ExercisesController < Api::BaseController
  skip_before_action :authenticate_via_token!, only: [:search]

  def search
    exercises = if params[:q].present?
      Exercise.where("name LIKE ?", "%#{Exercise.sanitize_sql_like(params[:q])}%")
    else
      Exercise.all
    end

    render json: exercises.order(:name).map { |e|
      { id: e.id, name: e.name, slug: e.slug,
        has_reps: e.has_reps, has_weight: e.has_weight,
        has_duration: e.has_duration, has_distance: e.has_distance }
    }
  end
end
