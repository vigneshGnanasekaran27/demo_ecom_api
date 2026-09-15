class AddMissingIndexesFromPhase2Audit < ActiveRecord::Migration[8.1]
  # DB-21: audit pass over every Phase 2 table for frequently-filtered columns
  # that a plain t.references didn't already auto-index (BACKEND_RULES.md §7).
  # orders.user_id / orders.order_status / orders.created_at / products.category_id /
  # payments.razorpay_payment_id were already indexed in their creation migrations
  # (DB-06/DB-14/DB-17) — these four were the gaps:
  def change
    # Named explicitly in this task's own Expected Result.
    add_index :orders, :payment_status
    add_index :complaints, :status

    # Not named in the task text, but the same "frequently filtered status
    # column" pattern — admin abandoned-cart queries (ABANDONED-*) and the
    # public "active products only" listing (PRODUCT-08) filter on these
    # constantly, matching the audit's actual objective (not just its examples).
    add_index :carts, :status
    add_index :products, :status
  end
end
