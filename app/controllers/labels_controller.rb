class LabelsController < ApplicationController
  before_action :set_label, only: [:edit, :update, :destroy]

  def index
    @labels = Label.order(:name)
  end

  def new
    @label = Label.new
  end

  def create
    @label = Label.new(label_params)
    if @label.save
      redirect_to labels_path, notice: "#{@label.name} label created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @label.update(label_params)
      redirect_to labels_path, notice: "#{@label.name} label updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @label.destroy
    redirect_to labels_path, notice: "Label deleted."
  end

  private

  def set_label
    @label = Label.find(params[:id])
  end

  def label_params
    params.require(:label).permit(:name, :slug, :color)
  end
end
