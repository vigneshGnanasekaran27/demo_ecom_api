module Api
  module V1
    module Manager
      # Managing a product's images is authorized as "updating the product"
      # (ProductPolicy#update?, PRODUCT-11) — there's no separate
      # ProductImagePolicy, since image management isn't a distinct resource
      # from the manager's point of view.
      class ProductImagesController < BaseController
        before_action :authenticate_request!
        before_action :set_product
        before_action { authorize @product, :update? }
        before_action :set_product_image, only: [ :update, :destroy ]

        # POST /api/v1/manager/products/:product_id/images
        #
        # Saved *before* attaching: attaching to an unsaved record just stages
        # the upload for the next save, deferring the real network call (and
        # any failure) outside this action's error handling entirely.
        # Attaching to an already-persisted record uploads immediately, so a
        # Cloudinary failure surfaces right here and the half-created record
        # (metadata with no image) is cleaned up rather than left behind.
        def create
          product_image = @product.product_images.new(
            position: params[:position].presence || next_position,
            alt_text: params[:alt_text]
          )
          return render_validation_error(product_image) unless product_image.save

          if params[:image].present?
            begin
              product_image.image.attach(params[:image])
            rescue StandardError => e
              Rails.logger.error("Product image upload failed: #{e.class}: #{e.message}")
              product_image.destroy
              return render json: {
                error: { code: "UPLOAD_FAILED", message: "Unable to upload image. Please try again." }
              }, status: :unprocessable_entity
            end
          end

          render json: { data: ProductImageSerializer.new(product_image).as_json }, status: :created
        end

        # PATCH /api/v1/manager/products/:product_id/images/:id (reorder / alt_text)
        def update
          if @product_image.update(product_image_params)
            render json: { data: ProductImageSerializer.new(@product_image).as_json }
          else
            render_validation_error(@product_image)
          end
        end

        # DELETE /api/v1/manager/products/:product_id/images/:id
        def destroy
          @product_image.destroy
          head :no_content
        end

        private

        def set_product
          @product = Product.find(params[:product_id])
        end

        def set_product_image
          @product_image = @product.product_images.find(params[:id])
        end

        def product_image_params
          params.permit(:position, :alt_text)
        end

        def next_position
          (@product.product_images.maximum(:position) || -1) + 1
        end
      end
    end
  end
end
