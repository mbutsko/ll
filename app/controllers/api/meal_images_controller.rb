module Api
  class MealImagesController < BaseController
    def create
      image_data = params[:image_data]
      media_type = params[:media_type] || "image/jpeg"

      unless image_data.present?
        return render json: { error: "image_data is required (base64-encoded)" }, status: :unprocessable_entity
      end

      analyzer = MealImageAnalyzer.new(image_data: image_data, media_type: media_type, user: current_user)
      result = analyzer.analyze
      foods_data = result["foods"]

      if foods_data.blank?
        return render json: { message: "No foods identified", food_logs: [] }, status: :ok
      end

      created_logs = []

      foods_data.each do |food_data|
        slug = food_data["name"].parameterize
        food = Food.find_or_create_by!(slug: slug) do |f|
          f.name = food_data["name"].titleize
          f.default_unit = food_data["unit"]
          f.default_serving = food_data["value"]
        end

        log = current_user.food_logs.create!(
          food: food,
          value: food_data["value"],
          unit: food_data["unit"],
          consumed_at: params[:consumed_at] || Time.current
        )

        created_logs << {
          id: log.id,
          food_name: food.name,
          food_slug: food.slug,
          value: log.value,
          unit: log.unit,
          consumed_at: log.consumed_at
        }
      end

      render json: { food_logs: created_logs }, status: :created
    rescue JSON::ParserError
      render json: { error: "Failed to parse AI response" }, status: :unprocessable_entity
    rescue Anthropic::Errors::APIError => e
      render json: { error: "AI analysis failed: #{e.message}" }, status: :service_unavailable
    end
  end
end
