class WeightEntriesController < ApplicationController
  def create
    @weight_entry = current_user.weight_entries.build(weight_entry_params.merge(date: Date.current))

    if @weight_entry.save
      redirect_to root_path
    else
      redirect_to root_path, alert: @weight_entry.errors.full_messages.to_sentence
    end
  end

  private

  def weight_entry_params
    params.require(:weight_entry).permit(:value)
  end
end
