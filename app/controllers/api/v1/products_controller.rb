module Api
  module V1
    class ProductsController < BaseController
      DEFAULT_PER_PAGE = 20
      MAX_PER_PAGE = 100

      # GET /api/v1/products?q=turmeric&category=whole-spices
      #
      # Public — active products only, paginated, optionally searched by
      # name and/or filtered by category slug (matches the links
      # CategoryShowcase already generates on the landing page).
      def index
        page = [ params[:page].to_i, 1 ].max
        per_page = params[:per_page].present? ? params[:per_page].to_i.clamp(1, MAX_PER_PAGE) : DEFAULT_PER_PAGE

        scope = Product.active.order(:position, :name)
        if params[:q].present?
          # Qualified as products.name — combined with the category join
          # below, an unqualified "name" is ambiguous (categories also has
          # a name column) and raises PG::AmbiguousColumn.
          scope = scope.where("products.name ILIKE ?", "%#{Product.sanitize_sql_like(params[:q])}%")
        end
        if params[:category].present?
          scope = scope.joins(:category).where(categories: { slug: params[:category] })
        end
        total = scope.count
        # Eager-load images (for ProductListSerializer#thumbnail_url) to avoid
        # an N+1 query per product (BACKEND_RULES.md §34).
        products = scope.offset((page - 1) * per_page).limit(per_page)
          .includes(product_images: { image_attachment: :blob })

        render json: {
          data: products.map { |product| ProductListSerializer.new(product).as_json },
          meta: { page: page, per_page: per_page, total: total }
        }
      end

      # GET /api/v1/products/:slug
      #
      # Public — active only; unknown/inactive slug both 404 via the shared
      # ActiveRecord::RecordNotFound rescue on BaseController. Full detail
      # (ProductDetailSerializer).
      def show
        product = Product.active.find_by!(slug: params[:slug])
        render json: { data: ProductDetailSerializer.new(product).as_json }
      end
    end
  end
end
