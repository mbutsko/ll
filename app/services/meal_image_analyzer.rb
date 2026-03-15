class MealImageAnalyzer
  def initialize(image_data:, media_type:, user:)
    @image_data = image_data
    @media_type = media_type
    @user = user
  end

  def analyze
    client = Anthropic::Client.new(api_key: ENV.fetch("ANTHROPIC_API_KEY"))

    response = client.messages.create(
      model: "claude-sonnet-4-5-20250929",
      max_tokens: 1024,
      messages: [
        {
          role: "user",
          content: [
            {
              type: "image",
              source: {
                type: "base64",
                media_type: @media_type,
                data: @image_data
              }
            },
            {
              type: "text",
              text: prompt
            }
          ]
        }
      ]
    )

    text = response.content.first.text
    JSON.parse(text)
  end

  private

  def prompt
    known_foods = @user.food_logs
      .group(:food_id)
      .having("COUNT(*) >= 3")
      .count
      .keys
      .then { |ids| Food.where(id: ids).pluck(:name) }

    parts = []
    parts << "Analyze this image of a meal. Identify each distinct food item visible."

    if known_foods.any?
      food_list = known_foods.map { |name| "- #{name}" }.join("\n")
      parts << <<~HINT
        The user frequently logs these foods, so there's a good chance the items in this image match one of them. Prefer using these names when the food is a close match:
        #{food_list}
      HINT
    end

    parts << <<~INSTRUCTIONS
      For each food, estimate:
      - A reasonable name (lowercase, e.g. "scrambled eggs", "white rice", "grilled chicken breast")
      - The approximate quantity consumed
      - The unit of measurement (must be one of: grams, tablespoons, cups, ounces, pieces, ml)

      Respond ONLY with valid JSON — no markdown, no explanation. Use this exact format:

      {
        "foods": [
          {
            "name": "scrambled eggs",
            "value": 2,
            "unit": "pieces"
          }
        ]
      }

      If the image does not contain food, respond with: {"foods": []}
    INSTRUCTIONS

    parts.join("\n")
  end
end
