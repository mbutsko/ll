class RhrEntriesController < ApplicationController
  def create
    @rhr_entry = current_user.rhr_entries.build(rhr_entry_params.merge(date: Date.current))

    if @rhr_entry.save
      redirect_to root_path
    else
      redirect_to root_path, alert: @rhr_entry.errors.full_messages.to_sentence
    end
  end

  private

  def rhr_entry_params
    params.require(:rhr_entry).permit(:value)
  end
end
