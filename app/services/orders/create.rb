module Orders
  # Re-validates stock/price and creates the order atomically (AI_RULES.md
  # §8/§9, BACKEND_RULES.md §9). Never trusts the cart's stored
  # unit_price_cents or the frontend's displayed total — both are
  # recomputed here from each Product's live effective_price_cents inside
  # the same transaction that decrements stock, so a price change or a
  # concurrent sale between "viewing cart" and "placing order" can't produce
  # an incorrect or overselling order (original CHECKOUT-03 + CHECKOUT-05
  # combined into one service per DECISION-030's time-boxed scope).
  class Create
    Result = Struct.new(:success?, :order, :error_message, keyword_init: true)

    class InsufficientStockError < StandardError; end

    def self.call(...)
      new(...).call
    end

    def initialize(cart:, shipping_params:)
      @cart = cart
      @shipping_params = shipping_params
    end

    def call
      return failure("Your cart is empty") if cart.cart_items.empty?

      order = nil

      begin
        ActiveRecord::Base.transaction do
          line_items = reserve_stock_and_price!
          order = create_order!(line_items)
          cart.update!(status: "converted")
        end
      rescue InsufficientStockError => e
        return failure(e.message)
      rescue ActiveRecord::RecordInvalid => e
        return failure(e.record.errors.full_messages.to_sentence)
      end

      Result.new(success?: true, order: order, error_message: nil)
    end

    private

    attr_reader :cart, :shipping_params

    # Locks each product row, re-validates stock, decrements it with a
    # `WHERE stock_quantity >= quantity` guard (so a concurrent checkout for
    # the same last unit can't both succeed), and returns the snapshot data
    # needed to build order_items at today's real price.
    def reserve_stock_and_price!
      cart.cart_items.includes(:product).map do |item|
        product = Product.lock.find(item.product_id)

        if product.status != "active" || product.stock_quantity < item.quantity
          raise InsufficientStockError, "#{product.name} is no longer available in the requested quantity"
        end

        updated = Product.where(id: product.id)
                          .where("stock_quantity >= ?", item.quantity)
                          .update_all([ "stock_quantity = stock_quantity - ?", item.quantity ])
        raise InsufficientStockError, "#{product.name} is no longer available in the requested quantity" if updated.zero?

        unit_price_cents = product.effective_price_cents
        {
          product: product,
          quantity: item.quantity,
          unit_price_cents: unit_price_cents,
          line_total_cents: unit_price_cents * item.quantity
        }
      end
    end

    def create_order!(line_items)
      subtotal_cents = line_items.sum { |item| item[:line_total_cents] }

      order = Order.create!(
        owner_attributes.merge(
          subtotal_cents: subtotal_cents,
          discount_cents: 0,
          delivery_charge_cents: 0,
          total_cents: subtotal_cents,
          placed_at: Time.current,
          **shipping_attributes
        )
      )

      line_items.each do |item|
        order.order_items.create!(
          product: item[:product],
          product_name_snapshot: item[:product].name,
          unit_price_cents: item[:unit_price_cents],
          quantity: item[:quantity],
          discount_cents: 0,
          line_total_cents: item[:line_total_cents]
        )
      end

      order
    end

    def owner_attributes
      cart.user_id.present? ? { user_id: cart.user_id } : { guest_session_id: cart.guest_session_id }
    end

    def shipping_attributes
      {
        shipping_name: shipping_params[:name],
        shipping_phone: shipping_params[:phone],
        shipping_line1: shipping_params[:line1],
        shipping_line2: shipping_params[:line2],
        shipping_city: shipping_params[:city],
        shipping_state: shipping_params[:state],
        shipping_postal_code: shipping_params[:postal_code],
        shipping_landmark: shipping_params[:landmark],
        shipping_country: shipping_params[:country].presence || "India"
      }
    end

    def failure(message)
      Result.new(success?: false, order: nil, error_message: message)
    end
  end
end
