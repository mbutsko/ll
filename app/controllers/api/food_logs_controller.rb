module Api
  class FoodLogsController < BaseController
    def create
      food = Food.find_by(slug: params.dig(:food_log, :food_slug))
      return render json: { error: "Food not found" }, status: :not_found unless food

      log = current_user.food_logs.new(food_log_params)
      log.food = food
      log.consumed_at = params.dig(:food_log, :consumed_at) || Time.current

      if log.save
        render json: {
          id: log.id,
          food_slug: food.slug,
          value: log.value,
          unit: log.unit,
          consumed_at: log.consumed_at
        }, status: :created
      else
        render json: { error: log.errors.full_messages.join(", ") }, status: :unprocessable_entity
      end
    end

    private

    def food_log_params
      params.require(:food_log).permit(:value, :unit)
    end
  end
end
