class Api::FoodsController < Api::BaseController
  skip_before_action :authenticate_via_token!, only: [:search]

  def search
    foods = if params[:q].present?
      Food.where("name LIKE ?", "%#{Food.sanitize_sql_like(params[:q])}%")
    else
      Food.all
    end

    render json: foods.order(:name).map { |f|
      { id: f.id, name: f.name, slug: f.slug, default_unit: f.default_unit, default_serving: f.default_serving }
    }
  end
end
