module ApplicationHelper
  def label_color_classes(color)
    {
      "gray"   => "bg-gray-100 text-gray-700",
      "red"    => "bg-red-100 text-red-700",
      "orange" => "bg-orange-100 text-orange-700",
      "yellow" => "bg-yellow-100 text-yellow-700",
      "green"  => "bg-green-100 text-green-700",
      "blue"   => "bg-blue-100 text-blue-700",
      "purple" => "bg-purple-100 text-purple-700",
      "pink"   => "bg-pink-100 text-pink-700"
    }.fetch(color, "bg-gray-100 text-gray-700")
  end

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
