# Demo seed data (Phase 26, SEED-*). Each section should be idempotent
# (find_or_create_by!) so bin/rails db:seed is safe to re-run at any time.

# == Users =====================================================================
# Demo admin accounts (SEED-01). Credentials come from ENV only — never
# hardcoded (AI_RULES.md §10, BACKEND_RULES.md §30). An admin whose email
# ENV var is blank is simply skipped rather than seeded with a guessed
# value; if SEED_ADMIN_PASSWORD is blank, no admin accounts are (re)seeded.
admin_emails = [
  ENV["SEED_ADMIN_EMAIL_1"],
  ENV["SEED_ADMIN_EMAIL_2"],
  ENV["SEED_ADMIN_EMAIL_3"]
]
admin_password = ENV["SEED_ADMIN_PASSWORD"]

if admin_password.present?
  admin_emails.each_with_index do |email, index|
    next if email.blank?

    user = User.find_or_initialize_by(email: email.downcase.strip)
    user.full_name = "Admin #{index + 1}"
    user.password = admin_password
    user.role = "admin"
    user.save!
  end
else
  warn "SEED_ADMIN_PASSWORD not set — skipping admin account seeding."
end

# == Categories & Products (Indian spices catalog) ============================
# Populated ahead of the formal Phase 26 pass, specifically to give the
# premium landing page (Phase 5 follow-up) real category/product content to
# render instead of the placeholder "Electronics/Books/P08 Product NN" test
# fixtures left over from Phase 4 development.
#
# Each product gets 2 real (not fabricated) photos attached via
# ActiveStorage, sourced from db/seed_assets/spice_photos/ — see that
# directory's MANIFEST.md for what each file shows. Only 8 photos exist for
# the 7 curated products below, so a couple of products still share a photo
# rather than every SKU having one uniquely dedicated to it — reasonable for
# dummy/demo imagery, and preferable to forcing a bad match. DECISION-025
# covers why this replaced the earlier illustrated/generated-monogram
# approach, and DECISION-010/DECISION-025 cover local-disk vs. Cloudinary
# storage. The photo set was replaced 2026-09-16 (user-provided images) —
# the previous Wikimedia-sourced set is archived at
# db/seed_assets/spice_photos_legacy/, unused by this file. The catalog
# itself was trimmed from 20 products to 7 curated ones the same day (see
# the deactivation step below the `products` array) so the landing page's
# redesigned sections show a smaller, higher-quality set instead of padding
# for volume.
SPICE_PHOTOS_DIR = Rails.root.join("db/seed_assets/spice_photos")

# Always resets each product's photos to exactly the 2 filenames specified
# below, purging whatever was attached before (rather than the previous
# skip-if-already-attached behavior) — so re-running db:seed after changing
# the images: list actually replaces the old photos instead of leaving them
# in place.
def attach_seed_images!(product, filenames)
  product.product_images.find_each { |image| image.image.purge if image.image.attached? }
  product.product_images.destroy_all

  filenames.each_with_index do |filename, position|
    path = SPICE_PHOTOS_DIR.join(filename)
    image = product.product_images.create!(position: position, alt_text: product.name)
    image.image.attach(
      io: File.open(path),
      filename: filename,
      content_type: "image/png"
    )
  end
end

# Retire the old placeholder catalog by its known slugs only (never a blanket
# destroy_all) — safe because nothing else references these yet (Cart/Order
# models don't exist until later phases). Children before parents, products
# before categories, per Category's `restrict_with_error` associations.
%w[phones electronics books p08-cat].each do |slug|
  category = Category.find_by(slug: slug)
  next unless category

  category.products.destroy_all
  category.children.each { |child| child.products.destroy_all }
  category.destroy
end

categories = {}
[
  "whole-spices",
  "ground-spices",
  "blended-spices",
  "masalas"
].each_with_index do |slug, index|
  name = slug.tr("-", " ").split.map(&:capitalize).join(" ")
  categories[slug] = Category.find_or_create_by!(slug: slug) do |category|
    category.name = name
    category.position = index
  end
end

# position: explicit curation order (cross-category mix) rather than
# insertion order, so /api/v1/products (ordered by position, name) surfaces a
# varied "featured" set for the landing page's FeaturedProducts section.
# Trimmed 2026-09-16 from 20 products to these 7 — one or two per category so
# every "Shop by category" tile has real products behind it, a mix of
# discounted/full-price items, and one deliberately out-of-stock item
# (whole-cloves-laung) preserved so the out-of-stock badge stays demoable.
products = [
  { position: 0, category: "masalas", sku: "SPC-MS-01", slug: "classic-garam-masala",
    name: "Classic Garam Masala", price_cents: 18_900, discount_percent: 12, stock_quantity: 50,
    description: "A warm, aromatic blend of roasted whole spices, stone-ground in small batches.",
    specifications: { origin: "Kerala", net_weight_g: 100, form: "Blend", shelf_life_months: 12 },
    images: %w[garam-masala-blend.png cinnamon.png] },
  { position: 1, category: "ground-spices", sku: "SPC-GS-01", slug: "alleppey-turmeric-powder",
    name: "Alleppey Turmeric Powder", price_cents: 12_900, discount_percent: 15, stock_quantity: 60,
    description: "High-curcumin turmeric from Alleppey, sun-dried and stone-milled for deep colour and flavour.",
    specifications: { origin: "Alleppey, Kerala", net_weight_g: 200, form: "Ground", shelf_life_months: 18 },
    images: %w[turmeric-powder.png cumin-seeds.png] },
  { position: 2, category: "whole-spices", sku: "SPC-WS-02", slug: "green-cardamom-elaichi",
    name: "Green Cardamom (Elaichi)", price_cents: 39_900, discount_percent: 10, stock_quantity: 25,
    description: "Bold, floral pods hand-sorted for size and aroma — the queen of spices.",
    specifications: { origin: "Idukki, Kerala", net_weight_g: 50, form: "Whole", shelf_life_months: 24 },
    images: %w[cardamom-pods.png cinnamon.png] },
  { position: 3, category: "blended-spices", sku: "SPC-BS-01", slug: "masala-chai-blend",
    name: "Masala Chai Blend", price_cents: 24_900, discount_percent: 10, stock_quantity: 32,
    description: "Cardamom, ginger, cinnamon, and clove, balanced for a bold, milky cup of chai.",
    specifications: { origin: "Assam", net_weight_g: 100, form: "Blend", shelf_life_months: 12 },
    images: %w[cinnamon.png cardamom-pods.png] },
  { position: 4, category: "masalas", sku: "SPC-MS-02", slug: "sambar-masala",
    name: "Sambar Masala", price_cents: 15_900, discount_percent: 0, stock_quantity: 38,
    description: "A South Indian staple — roasted lentils and spices ground for authentic sambar.",
    specifications: { origin: "Tamil Nadu", net_weight_g: 200, form: "Blend", shelf_life_months: 12 },
    images: %w[coriander-seeds-powder.png black-pepper.png] },
  { position: 5, category: "ground-spices", sku: "SPC-GS-02", slug: "kashmiri-red-chilli-powder",
    name: "Kashmiri Red Chilli Powder", price_cents: 15_900, discount_percent: 0, stock_quantity: 55,
    description: "Mild heat, vivid colour — the classic chilli powder for a rich, restaurant-red gravy.",
    specifications: { origin: "Kashmir", net_weight_g: 200, form: "Ground", shelf_life_months: 18 },
    images: %w[red-chilli-powder.png garam-masala-blend.png] },
  { position: 6, category: "whole-spices", sku: "SPC-WS-05", slug: "whole-cloves-laung",
    name: "Whole Cloves (Laung)", price_cents: 17_900, discount_percent: 0, stock_quantity: 0,
    description: "Hand-picked clove buds, intensely aromatic — a pinch goes a long way.",
    specifications: { origin: "Tamil Nadu", net_weight_g: 50, form: "Whole", shelf_life_months: 24 },
    images: %w[cardamom-pods.png black-pepper.png] }
].freeze

products.each do |attrs|
  # find_or_initialize_by (not the previous find_or_create_by!) so catalog
  # data — category/name/price/discount/position/specifications — always
  # converges to what's declared here, even for a product that already
  # existed from an earlier seed run (this is what makes the position
  # renumbering below actually take effect on a re-seed). `stock_quantity`
  # is deliberately the one field left create-only: it changes via real
  # cart/order activity during a demo, and reseeding shouldn't silently
  # undo that mid-demo.
  product = Product.find_or_initialize_by(slug: attrs.fetch(:slug))
  product.category = categories.fetch(attrs.fetch(:category))
  product.sku = attrs.fetch(:sku)
  product.name = attrs.fetch(:name)
  product.description = attrs.fetch(:description)
  product.price_cents = attrs.fetch(:price_cents)
  product.discount_percent = attrs.fetch(:discount_percent)
  product.stock_quantity = attrs.fetch(:stock_quantity) if product.new_record?
  product.position = attrs.fetch(:position)
  product.specifications = attrs.fetch(:specifications).stringify_keys
  product.status = "active"
  product.save!

  attach_seed_images!(product, attrs.fetch(:images))
end

# Deactivate (never destroy) any previously-seeded product that's no longer
# in the curated list above. `CartItem`/`OrderItem` both `belongs_to
# :product` with no `dependent:` policy declared on Product's side, so
# destroying a product a real cart/order row already references would risk
# a foreign-key error or, worse, cascading into order history — a `Product`
# has an existing `active`/`inactive` status (AI_RULES.md §22's "Deactivate
# product") and `Product.active` is already what every public endpoint
# scopes on (`Api::V1::ProductsController`), so deactivating is the safe,
# reversible way to shrink what the storefront shows.
kept_slugs = products.map { |attrs| attrs.fetch(:slug) }
categories.each_value do |category|
  category.products.where.not(slug: kept_slugs).update_all(status: "inactive")
end

# == Orders =====================================================================
# A few historical orders (various order_status/payment_status combinations) so
# admin/warehouse/dispatch/delivery dashboards have data to demonstrate against.
#
#   Orders::Create.call(...)
