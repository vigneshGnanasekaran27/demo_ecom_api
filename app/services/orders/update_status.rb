module Orders
  # Single choke point for every order_status change (ORDER-01) — used by
  # the payment confirmation path and the admin console alike, so there is
  # exactly one place that knows which transitions are legal and exactly
  # one place that writes the audit trail (PROJECT_CONTEXT.md §10:
  # "arbitrary status transitions... are rejected", "every transition is
  # recorded in order_status_histories"). Never update order_status
  # directly outside this service.
  class UpdateStatus
    TRANSITIONS = {
      "pending_payment" => %w[confirmed cancelled],
      "confirmed" => %w[processing cancelled],
      "processing" => %w[packed cancelled],
      "packed" => %w[dispatched cancelled],
      "dispatched" => %w[out_for_delivery],
      "out_for_delivery" => %w[delivered],
      "delivered" => [],
      "cancelled" => []
    }.freeze

    Result = Struct.new(:success?, :order, :error_message, keyword_init: true)

    def self.call(...)
      new(...).call
    end

    def initialize(order:, new_status:, changed_by: nil, note: nil)
      @order = order
      @new_status = new_status.to_s
      @changed_by = changed_by
      @note = note
    end

    def call
      allowed = TRANSITIONS[order.order_status] || []
      unless allowed.include?(new_status)
        return failure("Cannot move order from '#{order.order_status}' to '#{new_status}'")
      end

      ActiveRecord::Base.transaction do
        order.update!(order_status: new_status, delivered_at: (Time.current if new_status == "delivered"))
        order.status_histories.create!(status: new_status, changed_by_user: changed_by, note: note)
      end

      Result.new(success?: true, order: order.reload, error_message: nil)
    end

    private

    attr_reader :order, :new_status, :changed_by, :note

    def failure(message)
      Result.new(success?: false, order: nil, error_message: message)
    end
  end
end
