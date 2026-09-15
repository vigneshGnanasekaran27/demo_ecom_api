module Api
  module V1
    module Manager
      # Manager-only write access to categories (PROJECT_CONTEXT.md §4 — admin
      # can only view). List/show are public (CategoriesController, PRODUCT-03).
      # Authorization goes through CategoryPolicy (PRODUCT-11) — formalized
      # from the ad hoc authorize_role! check used since PRODUCT-02.
      class CategoriesController < BaseController
        before_action :authenticate_request!
        before_action :set_category, only: [ :update, :destroy ]

        def create
          authorize Category
          category = Category.new(category_params)
          if category.save
            render json: { data: CategorySerializer.new(category).as_json }, status: :created
          else
            render_validation_error(category)
          end
        end

        def update
          authorize @category
          if @category.update(category_params)
            render json: { data: CategorySerializer.new(@category).as_json }
          else
            render_validation_error(@category)
          end
        end

        # "Deactivate" per the plan — categories have no active/status column
        # (unlike products), so removing a category is the closest real
        # equivalent. dependent: :restrict_with_error on Category protects
        # against deleting one that still has children or products.
        def destroy
          authorize @category
          if @category.destroy
            head :no_content
          else
            render_validation_error(@category)
          end
        end

        private

        def set_category
          @category = Category.find(params[:id])
        end

        def category_params
          params.permit(:name, :slug, :parent_id, :position)
        end
      end
    end
  end
end
