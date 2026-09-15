module Api
  module V1
    class CategoriesController < BaseController
      # GET /api/v1/categories
      #
      # Flat list (with parent_id), ordered for display — the categories
      # table has no "active"/status column to filter on, unlike products.
      def index
        categories = Category.ordered
        render json: { data: categories.map { |category| CategorySerializer.new(category).as_json } }
      end
    end
  end
end
