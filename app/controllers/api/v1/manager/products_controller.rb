module Api
  module V1
    module Manager
      # Manager-only write access to products (PROJECT_CONTEXT.md §4 — admin
      # can only view). "Deactivate" sets status: "inactive" rather than
      # deleting — products are referenced by order_items/cart_items/etc.
      # (FK RESTRICT by default), and DECISION-009 requires historical orders
      # to stay intact regardless of what happens to the underlying product.
      # Authorization goes through ProductPolicy (PRODUCT-11) — formalized
      # from the ad hoc authorize_role! check used since PRODUCT-06. Response
      # shape is ProductDetailSerializer (PRODUCT-10) — a manager benefits
      # from the full detail shape too.
      class ProductsController < BaseController
        before_action :authenticate_request!
        before_action :set_product, only: [ :update, :deactivate ]

        def create
          authorize Product
          product = Product.new(product_params)
          if product.save
            render json: { data: ProductDetailSerializer.new(product).as_json }, status: :created
          else
            render_validation_error(product)
          end
        end

        def update
          authorize @product
          if @product.update(product_params)
            render json: { data: ProductDetailSerializer.new(@product).as_json }
          else
            render_validation_error(@product)
          end
        end

        def deactivate
          authorize @product
          if @product.update(status: "inactive")
            render json: { data: ProductDetailSerializer.new(@product).as_json }
          else
            render_validation_error(@product)
          end
        end

        private

        def set_product
          @product = Product.find(params[:id])
        end

        def product_params
          params.permit(
            :category_id, :name, :slug, :sku, :description,
            :price_cents, :discount_percent, :stock_quantity, :status, :position,
            specifications: {}
          )
        end
      end
    end
  end
end
