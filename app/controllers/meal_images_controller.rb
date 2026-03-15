class MealImagesController < ApplicationController
  before_action :authenticate_user!

  def new
  end

  def create
    uploaded = params[:image]

    unless uploaded.present?
      return redirect_to new_meal_image_path, alert: "Please select an image."
    end

    image_data = Base64.strict_encode64(uploaded.read)
    media_type = uploaded.content_type

    analyzer = MealImageAnalyzer.new(image_data: image_data, media_type: media_type, user: current_user)
    result = analyzer.analyze
    foods_data = result["foods"]

    if foods_data.blank?
      return redirect_to root_path, notice: "No foods identified in the image."
    end

    foods_data.each do |food_data|
      slug = food_data["name"].parameterize
      food = Food.find_or_create_by!(slug: slug) do |f|
        f.name = food_data["name"].titleize
        f.default_unit = food_data["unit"]
        f.default_serving = food_data["value"]
      end

      current_user.food_logs.create!(
        food: food,
        value: food_data["value"],
        unit: food_data["unit"],
        consumed_at: Time.current
      )
    end

    names = foods_data.map { |f| f["name"].titleize }
    redirect_to root_path, notice: "Logged #{names.to_sentence} from image."
  rescue JSON::ParserError
    redirect_to new_meal_image_path, alert: "Failed to analyze image. Please try again."
  rescue Anthropic::Errors::APIError => e
    redirect_to new_meal_image_path, alert: "AI analysis failed: #{e.message}"
  end
end
