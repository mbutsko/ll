class StepEntriesController < ApplicationController
  def create
    @step_entry = current_user.step_entries.build(step_entry_params.merge(date: Date.current))

    if @step_entry.save
      redirect_to root_path
    else
      redirect_to root_path, alert: @step_entry.errors.full_messages.to_sentence
    end
  end

  private

  def step_entry_params
    params.require(:step_entry).permit(:value)
  end
end
