# Lean, card-level fields for /products index — no description/specifications
# (see ProductDetailSerializer for the full shape). Exposes up to the first 2
# images (not just a single thumbnail) so the card UI can show a hover
# preview cycling between views — the caller should eager-load
# product_images/attachments to avoid N+1s (see ProductsController#index).
class ProductListSerializer
  PREVIEW_IMAGE_COUNT = 2

  def initialize(product)
    @product = product
  end

  def as_json(*)
    {
      id: product.id,
      name: product.name,
      slug: product.slug,
      price_cents: product.price_cents,
      discount_percent: product.discount_percent,
      stock_quantity: product.stock_quantity,
      category_id: product.category_id,
      images: preview_images
    }
  end

  private

  attr_reader :product

  def preview_images
    # Product#product_images already defaults to order(:position), so once
    # eager-loaded this reads from memory, no extra query.
    product.product_images.first(PREVIEW_IMAGE_COUNT).map { |image| ProductImageSerializer.new(image).as_json }
  end
end
