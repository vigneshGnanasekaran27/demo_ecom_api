# Full detail for /products/:slug and manager product responses — includes
# specifications, nested category, and all images.
class ProductDetailSerializer
  def initialize(product)
    @product = product
  end

  def as_json(*)
    {
      id: product.id,
      name: product.name,
      slug: product.slug,
      sku: product.sku,
      description: product.description,
      price_cents: product.price_cents,
      discount_percent: product.discount_percent,
      stock_quantity: product.stock_quantity,
      status: product.status,
      specifications: product.specifications,
      position: product.position,
      category_id: product.category_id,
      category: CategorySerializer.new(product.category).as_json,
      images: product.product_images.map { |image| ProductImageSerializer.new(image).as_json }
    }
  end

  private

  attr_reader :product
end
