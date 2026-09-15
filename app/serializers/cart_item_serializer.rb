# Carries enough product detail (name/slug/image/stock) for the cart UI to
# render a real row without a second round-trip per item.
class CartItemSerializer
  def initialize(cart_item)
    @cart_item = cart_item
  end

  def as_json(*)
    {
      id: cart_item.id,
      product_id: cart_item.product_id,
      product: {
        name: product.name,
        slug: product.slug,
        stock_quantity: product.stock_quantity,
        image: product.product_images.first && ProductImageSerializer.new(product.product_images.first).as_json
      },
      quantity: cart_item.quantity,
      unit_price_cents: cart_item.current_unit_price_cents,
      line_total_cents: cart_item.line_total_cents
    }
  end

  private

  attr_reader :cart_item

  def product
    cart_item.product
  end
end
