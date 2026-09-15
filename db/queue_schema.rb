# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_09_15_041752) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "addresses", force: :cascade do |t|
    t.string "city", null: false
    t.string "country", default: "India", null: false
    t.datetime "created_at", null: false
    t.boolean "is_default", default: false, null: false
    t.string "landmark"
    t.string "line1", null: false
    t.string "line2"
    t.string "name", null: false
    t.string "phone", null: false
    t.string "postal_code", null: false
    t.string "state", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_addresses_on_user_id"
  end

  create_table "bundle_items", force: :cascade do |t|
    t.bigint "bundle_id", null: false
    t.integer "position", default: 0, null: false
    t.bigint "product_id", null: false
    t.index ["bundle_id"], name: "index_bundle_items_on_bundle_id"
    t.index ["product_id"], name: "index_bundle_items_on_product_id"
  end

  create_table "bundles", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.integer "bundle_price_cents"
    t.datetime "created_at", null: false
    t.string "name"
    t.bigint "primary_product_id"
    t.datetime "updated_at", null: false
    t.index ["primary_product_id"], name: "index_bundles_on_primary_product_id"
  end

  create_table "cart_items", force: :cascade do |t|
    t.bigint "cart_id", null: false
    t.datetime "created_at", null: false
    t.bigint "product_id", null: false
    t.integer "quantity", default: 1, null: false
    t.integer "unit_price_cents", null: false
    t.datetime "updated_at", null: false
    t.index ["cart_id"], name: "index_cart_items_on_cart_id"
    t.index ["product_id"], name: "index_cart_items_on_product_id"
  end

  create_table "carts", force: :cascade do |t|
    t.datetime "checkout_started_at"
    t.datetime "created_at", null: false
    t.uuid "guest_session_id"
    t.datetime "payment_started_at"
    t.string "status", default: "active", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["guest_session_id"], name: "index_carts_on_guest_session_id"
    t.index ["status"], name: "index_carts_on_status"
    t.index ["user_id"], name: "index_carts_on_user_id"
    t.check_constraint "status::text = ANY (ARRAY['active'::character varying, 'abandoned'::character varying, 'converted'::character varying]::text[])", name: "carts_status_check"
  end

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "parent_id"
    t.integer "position", default: 0, null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_categories_on_parent_id"
    t.index ["slug"], name: "index_categories_on_slug", unique: true
  end

  create_table "complaint_updates", force: :cascade do |t|
    t.bigint "complaint_id", null: false
    t.datetime "created_at", null: false
    t.text "note"
    t.string "status", null: false
    t.bigint "updated_by_user_id", null: false
    t.index ["complaint_id"], name: "index_complaint_updates_on_complaint_id"
    t.index ["updated_by_user_id"], name: "index_complaint_updates_on_updated_by_user_id"
    t.check_constraint "status::text = ANY (ARRAY['open'::character varying, 'under_review'::character varying, 'in_progress'::character varying, 'resolved'::character varying, 'closed'::character varying]::text[])", name: "complaint_updates_status_check"
  end

  create_table "complaints", force: :cascade do |t|
    t.string "complaint_type", null: false
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.bigint "order_id", null: false
    t.text "resolution_note"
    t.string "status", default: "open", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["order_id"], name: "index_complaints_on_order_id"
    t.index ["status"], name: "index_complaints_on_status"
    t.index ["user_id"], name: "index_complaints_on_user_id"
    t.check_constraint "complaint_type::text = ANY (ARRAY['damaged'::character varying, 'wrong_product'::character varying, 'missing_product'::character varying, 'delivery_issue'::character varying, 'payment_issue'::character varying, 'other'::character varying]::text[])", name: "complaints_complaint_type_check"
    t.check_constraint "status::text = ANY (ARRAY['open'::character varying, 'under_review'::character varying, 'in_progress'::character varying, 'resolved'::character varying, 'closed'::character varying]::text[])", name: "complaints_status_check"
  end

  create_table "guest_sessions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.datetime "first_seen_at", null: false
    t.datetime "last_seen_at", null: false
    t.string "phone"
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["token"], name: "index_guest_sessions_on_token", unique: true
    t.index ["user_id"], name: "index_guest_sessions_on_user_id"
  end

  create_table "offer_products", force: :cascade do |t|
    t.bigint "offer_id", null: false
    t.bigint "product_id", null: false
    t.index ["offer_id", "product_id"], name: "index_offer_products_on_offer_id_and_product_id", unique: true
    t.index ["offer_id"], name: "index_offer_products_on_offer_id"
    t.index ["product_id"], name: "index_offer_products_on_product_id"
  end

  create_table "offers", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "discount_type", null: false
    t.integer "discount_value", null: false
    t.datetime "ends_at"
    t.string "name", null: false
    t.datetime "starts_at"
    t.datetime "updated_at", null: false
    t.check_constraint "discount_type::text = ANY (ARRAY['percent'::character varying, 'flat'::character varying]::text[])", name: "offers_discount_type_check"
  end

  create_table "order_items", force: :cascade do |t|
    t.integer "discount_cents", default: 0, null: false
    t.integer "line_total_cents", null: false
    t.bigint "order_id", null: false
    t.bigint "product_id", null: false
    t.string "product_name_snapshot", null: false
    t.integer "quantity", default: 1, null: false
    t.integer "unit_price_cents", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
  end

  create_table "order_status_histories", force: :cascade do |t|
    t.bigint "changed_by_user_id"
    t.datetime "created_at", null: false
    t.text "note"
    t.bigint "order_id", null: false
    t.string "status", null: false
    t.index ["changed_by_user_id"], name: "index_order_status_histories_on_changed_by_user_id"
    t.index ["order_id"], name: "index_order_status_histories_on_order_id"
    t.check_constraint "status::text = ANY (ARRAY['pending_payment'::character varying, 'confirmed'::character varying, 'processing'::character varying, 'packed'::character varying, 'dispatched'::character varying, 'out_for_delivery'::character varying, 'delivered'::character varying, 'cancelled'::character varying]::text[])", name: "order_status_histories_status_check"
  end

  create_table "orders", force: :cascade do |t|
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.datetime "delivered_at"
    t.integer "delivery_charge_cents", default: 0, null: false
    t.integer "discount_cents", default: 0, null: false
    t.uuid "guest_session_id"
    t.string "order_number", null: false
    t.string "order_status", default: "pending_payment", null: false
    t.string "payment_status", default: "pending", null: false
    t.datetime "placed_at"
    t.string "razorpay_order_id"
    t.string "razorpay_payment_id"
    t.string "shipping_city", null: false
    t.string "shipping_country", default: "India", null: false
    t.string "shipping_landmark"
    t.string "shipping_line1", null: false
    t.string "shipping_line2"
    t.string "shipping_name", null: false
    t.string "shipping_phone", null: false
    t.string "shipping_postal_code", null: false
    t.string "shipping_state", null: false
    t.integer "subtotal_cents", null: false
    t.integer "total_cents", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["created_at"], name: "index_orders_on_created_at"
    t.index ["guest_session_id"], name: "index_orders_on_guest_session_id"
    t.index ["order_number"], name: "index_orders_on_order_number", unique: true
    t.index ["order_status"], name: "index_orders_on_order_status"
    t.index ["payment_status"], name: "index_orders_on_payment_status"
    t.index ["razorpay_order_id"], name: "index_orders_on_razorpay_order_id", unique: true
    t.index ["user_id"], name: "index_orders_on_user_id"
    t.check_constraint "order_status::text = ANY (ARRAY['pending_payment'::character varying, 'confirmed'::character varying, 'processing'::character varying, 'packed'::character varying, 'dispatched'::character varying, 'out_for_delivery'::character varying, 'delivered'::character varying, 'cancelled'::character varying]::text[])", name: "orders_order_status_check"
    t.check_constraint "payment_status::text = ANY (ARRAY['pending'::character varying, 'successful'::character varying, 'failed'::character varying, 'refunded'::character varying]::text[])", name: "orders_payment_status_check"
  end

  create_table "payment_events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "event_type", null: false
    t.jsonb "payload", default: {}, null: false
    t.bigint "payment_id"
    t.datetime "processed_at"
    t.string "razorpay_event_id", null: false
    t.index ["payment_id"], name: "index_payment_events_on_payment_id"
    t.index ["razorpay_event_id"], name: "index_payment_events_on_razorpay_event_id", unique: true
  end

  create_table "payments", force: :cascade do |t|
    t.integer "amount_cents", null: false
    t.datetime "created_at", null: false
    t.bigint "order_id", null: false
    t.jsonb "raw_response"
    t.string "razorpay_order_id"
    t.string "razorpay_payment_id"
    t.string "razorpay_signature"
    t.string "status", default: "created", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_payments_on_order_id"
    t.index ["razorpay_payment_id"], name: "index_payments_on_razorpay_payment_id"
    t.check_constraint "status::text = ANY (ARRAY['created'::character varying, 'authorized'::character varying, 'captured'::character varying, 'failed'::character varying, 'refunded'::character varying]::text[])", name: "payments_status_check"
  end

  create_table "product_images", force: :cascade do |t|
    t.string "alt_text"
    t.datetime "created_at", null: false
    t.integer "position", default: 0, null: false
    t.bigint "product_id", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_product_images_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "discount_percent", default: 0, null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.integer "price_cents", null: false
    t.string "sku", null: false
    t.string "slug", null: false
    t.jsonb "specifications", default: {}, null: false
    t.string "status", default: "active", null: false
    t.integer "stock_quantity", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["sku"], name: "index_products_on_sku", unique: true
    t.index ["slug"], name: "index_products_on_slug", unique: true
    t.index ["status"], name: "index_products_on_status"
  end

  create_table "solid_queue_batch_executions", force: :cascade do |t|
    t.bigint "batch_id", null: false
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.index ["batch_id"], name: "index_solid_queue_batch_executions_on_batch_id"
    t.index ["job_id"], name: "index_solid_queue_batch_executions_on_job_id", unique: true
  end

  create_table "solid_queue_batches", force: :cascade do |t|
    t.string "active_job_batch_id"
    t.integer "completed_jobs", default: 0, null: false
    t.datetime "created_at", null: false
    t.string "description"
    t.datetime "enqueued_at"
    t.datetime "failed_at"
    t.integer "failed_jobs", default: 0, null: false
    t.datetime "finished_at"
    t.text "metadata"
    t.text "on_failure"
    t.text "on_finish"
    t.text "on_success"
    t.integer "total_jobs", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["active_job_batch_id"], name: "index_solid_queue_batches_on_active_job_batch_id", unique: true
    t.index ["finished_at"], name: "index_solid_queue_batches_on_finished_at"
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.string "concurrency_key", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error"
    t.bigint "job_id", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "active_job_id"
    t.text "arguments"
    t.bigint "batch_id"
    t.string "class_name", null: false
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "finished_at"
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at"
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["batch_id"], name: "index_solid_queue_jobs_on_batch_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "queue_name", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "hostname"
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.text "metadata"
    t.string "name", null: false
    t.integer "pid", null: false
    t.bigint "supervisor_id"
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.datetime "run_at", null: false
    t.string "task_key", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.text "arguments"
    t.string "class_name"
    t.string "command", limit: 2048
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.integer "priority", default: 0
    t.string "queue_name"
    t.string "schedule", null: false
    t.boolean "static", default: true, null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.integer "value", default: 1, null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "full_name", null: false
    t.string "password_digest", null: false
    t.string "phone"
    t.string "role", default: "customer", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.check_constraint "role::text = ANY (ARRAY['customer'::character varying, 'admin'::character varying, 'manager'::character varying, 'warehouse'::character varying, 'dispatch'::character varying, 'delivery'::character varying]::text[])", name: "users_role_check"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "addresses", "users"
  add_foreign_key "bundle_items", "bundles"
  add_foreign_key "bundle_items", "products"
  add_foreign_key "bundles", "products", column: "primary_product_id"
  add_foreign_key "cart_items", "carts"
  add_foreign_key "cart_items", "products"
  add_foreign_key "carts", "guest_sessions"
  add_foreign_key "carts", "users"
  add_foreign_key "categories", "categories", column: "parent_id"
  add_foreign_key "complaint_updates", "complaints"
  add_foreign_key "complaint_updates", "users", column: "updated_by_user_id"
  add_foreign_key "complaints", "orders"
  add_foreign_key "complaints", "users"
  add_foreign_key "guest_sessions", "users"
  add_foreign_key "offer_products", "offers"
  add_foreign_key "offer_products", "products"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
  add_foreign_key "order_status_histories", "orders"
  add_foreign_key "order_status_histories", "users", column: "changed_by_user_id"
  add_foreign_key "orders", "guest_sessions"
  add_foreign_key "orders", "users"
  add_foreign_key "payment_events", "payments"
  add_foreign_key "payments", "orders"
  add_foreign_key "product_images", "products"
  add_foreign_key "products", "categories"
  add_foreign_key "solid_queue_batch_executions", "solid_queue_batches", column: "batch_id", on_delete: :cascade
  add_foreign_key "solid_queue_batch_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
end
