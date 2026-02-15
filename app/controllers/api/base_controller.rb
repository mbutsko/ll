class Api::BaseController < ActionController::Base
  skip_before_action :verify_authenticity_token
  before_action :authenticate_via_token!

  private

  def authenticate_via_token!
    token = request.headers["Authorization"]&.delete_prefix("Bearer ")
    @current_user = User.find_by(api_token: token) if token.present?

    unless @current_user
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end
end
