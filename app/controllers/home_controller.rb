class HomeController < ApplicationController
  def index
    @todays_weight = current_user.weight_entries.find_by(date: Date.current)
    @todays_hrv = current_user.hrv_entries.find_by(date: Date.current)
    @todays_rhr = current_user.rhr_entries.find_by(date: Date.current)
    @todays_steps = current_user.step_entries.find_by(date: Date.current)
  end
end
