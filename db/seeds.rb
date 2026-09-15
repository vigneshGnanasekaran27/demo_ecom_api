# Demo seed data (Phase 26, SEED-*). Each section should be idempotent
# (find_or_create_by!) so bin/rails db:seed is safe to re-run at any time.

# == Users =====================================================================
# One account per role (admin, manager, warehouse, dispatch, delivery) plus a
# sample customer or two, per PROJECT_CONTEXT.md §4.
#
#   User.find_or_create_by!(email: "admin@example.com") do |user|
#     user.full_name = "Demo Admin"
#     user.password = "..."
#     user.role = "admin"
#   end

# == Categories & Products (Indian spices catalog) ============================
# Populated ahead of the formal Phase 26 pass, specifically to give the
# premium landing page (Phase 5 follow-up) real category/product content to
# render instead of the placeholder "Electronics/Books/P08 Product NN" test
# fixtures left over from Phase 4 development.
#
# Each product gets 2 real (not fabricated) photos attached via
# ActiveStorage, sourced from db/seed_assets/spice_photos/ — see that
# directory's MANIFEST.md for the Commons source/license of each file, and
# for a list of rejected candidates (several Commons search results turned
# out to be real competitor brands' actual packaged-product photography,
# which must never be displayed as if it were this demo's own product).
# Several products share a photo from that small curated pool rather than
# having one uniquely dedicated to each SKU — reasonable for dummy/demo
# imagery, and preferable to forcing a bad match. DECISION-025 covers why
# this replaced the earlier illustrated/generated-monogram approach, and
# DECISION-010/DECISION-025 cover local-disk vs. Cloudinary storage.
SPICE_PHOTOS_DIR = Rails.root.join("db/seed_assets/spice_photos")

def attach_seed_image!(product, filename, position)
  return if product.product_images.exists?(position: position)

  path = SPICE_PHOTOS_DIR.join(filename)
  image = product.product_images.create!(position: position, alt_text: product.name)
  image.image.attach(
    io: File.open(path),
    filename: filename,
    content_type: "image/jpeg"
  )
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
products = [
  { position: 0, category: "masalas", sku: "SPC-MS-01", slug: "classic-garam-masala",
    name: "Classic Garam Masala", price_cents: 18_900, discount_percent: 12, stock_quantity: 50,
    description: "A warm, aromatic blend of roasted whole spices, stone-ground in small batches.",
    specifications: { origin: "Kerala", net_weight_g: 100, form: "Blend", shelf_life_months: 12 },
    images: %w[sambar-powder.jpg detail-spices-kitchen.jpg] },
  { position: 1, category: "ground-spices", sku: "SPC-GS-01", slug: "alleppey-turmeric-powder",
    name: "Alleppey Turmeric Powder", price_cents: 12_900, discount_percent: 15, stock_quantity: 60,
    description: "High-curcumin turmeric from Alleppey, sun-dried and stone-milled for deep colour and flavour.",
    specifications: { origin: "Alleppey, Kerala", net_weight_g: 200, form: "Ground", shelf_life_months: 18 },
    images: %w[turmeric-powder.jpg detail-spices-kitchen.jpg] },
  { position: 2, category: "ground-spices", sku: "SPC-GS-02", slug: "kashmiri-red-chilli-powder",
    name: "Kashmiri Red Chilli Powder", price_cents: 15_900, discount_percent: 0, stock_quantity: 55,
    description: "Mild heat, vivid colour — the classic chilli powder for a rich, restaurant-red gravy.",
    specifications: { origin: "Kashmir", net_weight_g: 200, form: "Ground", shelf_life_months: 18 },
    images: %w[red-chilli-powder.jpg detail-spices-assortment.jpg] },
  { position: 3, category: "blended-spices", sku: "SPC-BS-03", slug: "hyderabadi-biryani-spice-mix",
    name: "Hyderabadi Biryani Spice Mix", price_cents: 29_900, discount_percent: 0, stock_quantity: 22,
    description: "A layered blend built for dum biryani — whole and ground spices in one authentic mix.",
    specifications: { origin: "Hyderabad", net_weight_g: 150, form: "Blend", shelf_life_months: 12 },
    images: %w[detail-spices-assortment.jpg cinnamon-sticks.jpg] },
  { position: 4, category: "whole-spices", sku: "SPC-WS-02", slug: "green-cardamom-elaichi",
    name: "Green Cardamom (Elaichi)", price_cents: 39_900, discount_percent: 10, stock_quantity: 25,
    description: "Bold, floral pods hand-sorted for size and aroma — the queen of spices.",
    specifications: { origin: "Idukki, Kerala", net_weight_g: 50, form: "Whole", shelf_life_months: 24 },
    images: %w[green-cardamom.jpg detail-spices-assortment.jpg] },
  { position: 5, category: "blended-spices", sku: "SPC-BS-01", slug: "masala-chai-blend",
    name: "Masala Chai Blend", price_cents: 24_900, discount_percent: 10, stock_quantity: 32,
    description: "Cardamom, ginger, cinnamon, and clove, balanced for a bold, milky cup of chai.",
    specifications: { origin: "Assam", net_weight_g: 100, form: "Blend", shelf_life_months: 12 },
    images: %w[masala-chai-spices.jpg detail-spices-assortment.jpg] },
  { position: 6, category: "whole-spices", sku: "SPC-WS-03", slug: "ceylon-cinnamon-sticks",
    name: "Ceylon Cinnamon Sticks (Dalchini)", price_cents: 19_900, discount_percent: 0, stock_quantity: 35,
    description: "True cinnamon, thin-barked and delicately sweet — softer than cassia.",
    specifications: { origin: "Sri Lanka", net_weight_g: 100, form: "Whole", shelf_life_months: 24 },
    images: %w[cinnamon-sticks.jpg detail-spices-kitchen.jpg] },
  { position: 7, category: "masalas", sku: "SPC-MS-02", slug: "sambar-masala",
    name: "Sambar Masala", price_cents: 15_900, discount_percent: 0, stock_quantity: 38,
    description: "A South Indian staple — roasted lentils and spices ground for authentic sambar.",
    specifications: { origin: "Tamil Nadu", net_weight_g: 200, form: "Blend", shelf_life_months: 12 },
    images: %w[sambar-powder.jpg detail-spices-assortment.jpg] },
  { position: 8, category: "whole-spices", sku: "SPC-WS-01", slug: "kashmiri-whole-red-chillies",
    name: "Kashmiri Whole Red Chillies", price_cents: 14_900, discount_percent: 0, stock_quantity: 40,
    description: "Sun-dried whole chillies prized for colour more than heat.",
    specifications: { origin: "Kashmir", net_weight_g: 100, form: "Whole", shelf_life_months: 18 },
    images: %w[whole-red-chillies.jpg detail-spices-kitchen.jpg] },
  { position: 9, category: "whole-spices", sku: "SPC-WS-04", slug: "black-peppercorns",
    name: "Black Peppercorns (Kali Mirch)", price_cents: 24_900, discount_percent: 0, stock_quantity: 30,
    description: "Sun-dried Malabar peppercorns with a sharp, citrusy bite.",
    specifications: { origin: "Wayanad, Kerala", net_weight_g: 100, form: "Whole", shelf_life_months: 24 },
    images: %w[black-peppercorns.jpg detail-spices-assortment.jpg] },
  { position: 10, category: "whole-spices", sku: "SPC-WS-05", slug: "whole-cloves-laung",
    name: "Whole Cloves (Laung)", price_cents: 17_900, discount_percent: 0, stock_quantity: 0,
    description: "Hand-picked clove buds, intensely aromatic — a pinch goes a long way.",
    specifications: { origin: "Tamil Nadu", net_weight_g: 50, form: "Whole", shelf_life_months: 24 },
    images: %w[whole-cloves.jpg detail-spices-kitchen.jpg] },
  { position: 11, category: "whole-spices", sku: "SPC-WS-06", slug: "star-anise",
    name: "Star Anise (Chakra Phool)", price_cents: 22_900, discount_percent: 0, stock_quantity: 20,
    description: "Deeply fragrant star-shaped pods, essential to biryani and Chinese five-spice alike.",
    specifications: { origin: "Northeast India", net_weight_g: 50, form: "Whole", shelf_life_months: 24 },
    images: %w[star-anise.jpg detail-spices-assortment.jpg] },
  { position: 12, category: "ground-spices", sku: "SPC-GS-03", slug: "coriander-powder-dhania",
    name: "Coriander Powder (Dhania)", price_cents: 9_900, discount_percent: 0, stock_quantity: 50,
    description: "Lightly roasted and stone-ground for a warm, citrusy base note.",
    specifications: { origin: "Rajasthan", net_weight_g: 200, form: "Ground", shelf_life_months: 18 },
    images: %w[detail-spices-assortment.jpg detail-spices-kitchen.jpg] },
  { position: 13, category: "ground-spices", sku: "SPC-GS-04", slug: "roasted-cumin-powder-jeera",
    name: "Roasted Cumin Powder (Jeera)", price_cents: 14_900, discount_percent: 0, stock_quantity: 45,
    description: "Slow-roasted before milling for a deep, nutty aroma.",
    specifications: { origin: "Gujarat", net_weight_g: 100, form: "Ground", shelf_life_months: 18 },
    images: %w[cumin-seeds.jpg detail-spices-kitchen.jpg] },
  { position: 14, category: "ground-spices", sku: "SPC-GS-05", slug: "black-pepper-powder",
    name: "Black Pepper Powder", price_cents: 21_900, discount_percent: 0, stock_quantity: 28,
    description: "Freshly milled from whole Malabar peppercorns for maximum bite.",
    specifications: { origin: "Wayanad, Kerala", net_weight_g: 100, form: "Ground", shelf_life_months: 18 },
    images: %w[ground-black-pepper.jpg black-peppercorns.jpg] },
  { position: 15, category: "blended-spices", sku: "SPC-BS-02", slug: "chaat-masala",
    name: "Chaat Masala", price_cents: 12_900, discount_percent: 0, stock_quantity: 40,
    description: "Tangy, smoky, and a little salty — finishes street food and fruit alike.",
    specifications: { origin: "Delhi", net_weight_g: 100, form: "Blend", shelf_life_months: 12 },
    images: %w[sambar-powder.jpg detail-spices-kitchen.jpg] },
  { position: 16, category: "blended-spices", sku: "SPC-BS-04", slug: "tandoori-masala",
    name: "Tandoori Masala", price_cents: 17_900, discount_percent: 0, stock_quantity: 26,
    description: "Smoky, brick-red marinade spice built for the tandoor.",
    specifications: { origin: "Punjab", net_weight_g: 100, form: "Blend", shelf_life_months: 12 },
    images: %w[red-chilli-powder.jpg sambar-powder.jpg] },
  { position: 17, category: "masalas", sku: "SPC-MS-03", slug: "rasam-powder",
    name: "Rasam Powder", price_cents: 13_900, discount_percent: 0, stock_quantity: 33,
    description: "Peppery, tamarind-friendly spice mix for a comforting South Indian rasam.",
    specifications: { origin: "Tamil Nadu", net_weight_g: 100, form: "Blend", shelf_life_months: 12 },
    images: %w[sambar-powder.jpg detail-spices-kitchen.jpg] },
  { position: 18, category: "masalas", sku: "SPC-MS-04", slug: "pav-bhaji-masala",
    name: "Pav Bhaji Masala", price_cents: 14_900, discount_percent: 0, stock_quantity: 0,
    description: "The signature blend behind Mumbai's favourite street-food mash.",
    specifications: { origin: "Maharashtra", net_weight_g: 100, form: "Blend", shelf_life_months: 12 },
    images: %w[red-chilli-powder.jpg detail-spices-assortment.jpg] },
  { position: 19, category: "masalas", sku: "SPC-MS-05", slug: "kitchen-king-masala",
    name: "Kitchen King Masala", price_cents: 16_900, discount_percent: 0, stock_quantity: 29,
    description: "An all-purpose blend for everyday curries and vegetable dishes.",
    specifications: { origin: "Uttar Pradesh", net_weight_g: 100, form: "Blend", shelf_life_months: 12 },
    images: %w[sambar-powder.jpg ground-black-pepper.jpg] }
].freeze

products.each do |attrs|
  category_slug = attrs.fetch(:category)
  product = Product.find_or_create_by!(slug: attrs.fetch(:slug)) do |p|
    p.category = categories.fetch(category_slug)
    p.sku = attrs.fetch(:sku)
    p.name = attrs.fetch(:name)
    p.description = attrs.fetch(:description)
    p.price_cents = attrs.fetch(:price_cents)
    p.discount_percent = attrs.fetch(:discount_percent)
    p.stock_quantity = attrs.fetch(:stock_quantity)
    p.position = attrs.fetch(:position)
    p.specifications = attrs.fetch(:specifications).stringify_keys
    p.status = "active"
  end

  attrs.fetch(:images).each_with_index do |filename, index|
    attach_seed_image!(product, filename, index)
  end
end

# == Orders =====================================================================
# A few historical orders (various order_status/payment_status combinations) so
# admin/warehouse/dispatch/delivery dashboards have data to demonstrate against.
#
#   Orders::Create.call(...)
