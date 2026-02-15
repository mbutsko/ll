class ApiTokensController < ApplicationController
  def regenerate
    current_user.generate_api_token!
    redirect_to root_path, notice: "API token regenerated"
  end
end
