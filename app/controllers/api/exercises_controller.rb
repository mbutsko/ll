class Api::ExercisesController < Api::BaseController
  skip_before_action :authenticate_via_token!, only: [:search]

  def search
    exercises = if params[:q].present?
      Exercise.where("name LIKE ?", "%#{Exercise.sanitize_sql_like(params[:q])}%")
    else
      Exercise.all
    end

    render json: exercises.order(:name).map { |e|
      { id: e.id, name: e.name, slug: e.slug, exercise_type: e.exercise_type, unit_label: e.unit_label }
    }
  end
end
