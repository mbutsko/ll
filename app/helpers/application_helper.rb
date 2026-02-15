module ApplicationHelper
  def time_greeting
    hour = Time.current.hour
    if hour < 12
      "morning"
    elsif hour < 17
      "afternoon"
    else
      "evening"
    end
  end
end
