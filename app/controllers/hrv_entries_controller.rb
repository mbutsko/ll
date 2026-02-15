class HrvEntriesController < ApplicationController
  def create
    @hrv_entry = current_user.hrv_entries.build(hrv_entry_params.merge(date: Date.current))

    if @hrv_entry.save
      redirect_to root_path
    else
      redirect_to root_path, alert: @hrv_entry.errors.full_messages.to_sentence
    end
  end

  private

  def hrv_entry_params
    params.require(:hrv_entry).permit(:value)
  end
end
