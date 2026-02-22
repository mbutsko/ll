class ExercisesController < ApplicationController
  before_action :set_exercise, only: [:edit, :update, :destroy]

  def index
    @exercises = Exercise.order(:name)
  end

  def new
    @exercise = Exercise.new
  end

  def create
    @exercise = Exercise.new(exercise_params)
    if @exercise.save
      redirect_to exercises_path, notice: "#{@exercise.name} exercise created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @exercise.update(exercise_params)
      redirect_to exercises_path, notice: "#{@exercise.name} exercise updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @exercise.destroy
    redirect_to exercises_path, notice: "Exercise deleted."
  end

  private

  def set_exercise
    @exercise = Exercise.find(params[:id])
  end

  def exercise_params
    params.require(:exercise).permit(:name, :slug, :has_reps, :has_weight, :has_duration, :has_distance)
  end
end
