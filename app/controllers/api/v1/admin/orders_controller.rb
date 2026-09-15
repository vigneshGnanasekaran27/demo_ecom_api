module Api
  module V1
    module Admin
      # Single internal console, admin-only (DECISION-032 — simplified back
      # from the short-lived dispatch/delivery separate-login model:
      # "Orders", "Dispatch", and "Delivery" are just curated views inside
      # one admin account now, not separate role-gated logins). Every
      # action here requires the admin role; there is no per-transition
      # role restriction beyond that — Orders::UpdateStatus's own state
      # machine is the only gate on which status changes are legal at all.
      class OrdersController < BaseController
        # Orders the dispatch team is actively working (confirmed through
        # packed, not yet dispatched) — the fixed scope behind ?stage=dispatch.
        DISPATCH_STAGE_STATUSES = %w[confirmed processing packed].freeze

        # Orders the delivery team is actively working (dispatched, on the
        # way) — the fixed scope behind ?stage=delivery.
        DELIVERY_STAGE_STATUSES = %w[dispatched out_for_delivery].freeze

        before_action :authenticate_request!
        before_action { authorize_role!(:admin) }
        before_action :set_order, only: [ :show, :status ]

        # GET /api/v1/admin/orders?status=confirmed
        # GET /api/v1/admin/orders?status=payment_failed
        # GET /api/v1/admin/orders?stage=dispatch|delivery
        # GET /api/v1/admin/orders?from=2026-09-01&to=2026-09-15
        #
        # Never includes abandoned checkouts (pending_payment with no
        # payment ever attempted) — those live under #abandoned instead.
        # "payment_failed" is a synthetic status: pending_payment orders
        # where a real payment attempt was made and rejected.
        def index
          scope = real_orders_scope.order(created_at: :desc)
          scope = apply_status_or_stage(scope)
          scope = scope.where(created_at: date_range) if params[:from].present? || params[:to].present?

          page = [ params[:page].to_i, 1 ].max
          per_page = params[:per_page].present? ? params[:per_page].to_i.clamp(1, 100) : 25
          total = scope.count
          orders = scope.offset((page - 1) * per_page).limit(per_page).includes(:user, :order_items)

          render json: {
            data: orders.map { |order| AdminOrderListSerializer.new(order).as_json },
            meta: { page: page, per_page: per_page, total: total }
          }
        end

        # GET /api/v1/admin/orders/abandoned
        #
        # Checkouts where the customer entered a shipping address (an
        # Order row exists, per Orders::Create) but never completed or
        # even attempted payment — payment_status is still "pending", not
        # "failed". Never surfaced as an order anywhere in the admin UI.
        def abandoned
          scope = Order.where(order_status: "pending_payment", payment_status: "pending").order(created_at: :desc)

          page = [ params[:page].to_i, 1 ].max
          per_page = params[:per_page].present? ? params[:per_page].to_i.clamp(1, 100) : 25
          total = scope.count
          orders = scope.offset((page - 1) * per_page).limit(per_page).includes(:user, :order_items, :payments)

          render json: {
            data: orders.map { |order| AdminOrderDetailSerializer.new(order).as_json },
            meta: { page: page, per_page: per_page, total: total }
          }
        end

        # GET /api/v1/admin/orders/:id
        def show
          render json: { data: AdminOrderDetailSerializer.new(@order).as_json }
        end

        # PATCH /api/v1/admin/orders/:id/status
        def status
          result = Orders::UpdateStatus.call(
            order: @order,
            new_status: params[:status],
            changed_by: current_user,
            note: params[:note]
          )

          if result.success?
            render json: { data: OrderSerializer.new(result.order).as_json }
          else
            render json: { error: { code: "INVALID_TRANSITION", message: result.error_message } }, status: :unprocessable_entity
          end
        end

        # GET /api/v1/admin/orders/receipts?from=2026-09-01&to=2026-09-15&status=packed
        #
        # Batch receipt data for printing/downloading (individual or
        # filtered/bulk) — one JSON array of full order details; the
        # frontend renders each as a printable receipt and prints them as
        # one multi-page job. Never includes abandoned checkouts.
        def receipts
          scope = real_orders_scope.where(created_at: date_range)
          scope = apply_status_or_stage(scope)
          orders = scope.order(created_at: :asc).includes(:order_items, :payments, :user)

          render json: { data: orders.map { |order| AdminOrderDetailSerializer.new(order).as_json } }
        end

        private

        def set_order
          @order = Order.find(params[:id])
        end

        # Excludes abandoned checkouts (pending_payment + payment pending)
        # from every "real order" view — the one place that rule lives.
        def real_orders_scope
          Order.where.not(order_status: "pending_payment").or(Order.where(payment_status: "failed"))
        end

        def apply_status_or_stage(scope)
          if params[:stage] == "dispatch"
            scope.where(order_status: DISPATCH_STAGE_STATUSES)
          elsif params[:stage] == "delivery"
            scope.where(order_status: DELIVERY_STAGE_STATUSES)
          elsif params[:status] == "payment_failed"
            scope.where(order_status: "pending_payment", payment_status: "failed")
          elsif params[:status].present?
            scope.where(order_status: params[:status])
          else
            scope
          end
        end

        def date_range
          from = params[:from].present? ? Date.parse(params[:from]).beginning_of_day : 100.years.ago
          to = params[:to].present? ? Date.parse(params[:to]).end_of_day : Time.current
          from..to
        rescue ArgumentError
          100.years.ago..Time.current
        end
      end
    end
  end
end
