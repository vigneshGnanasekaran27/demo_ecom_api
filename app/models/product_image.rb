class ProductImage < ApplicationRecord
  belongs_to :product
  # Stored on Cloudinary (DECISION-010) via config.active_storage.service,
  # never Render's local disk. One attached file per row — position/alt_text
  # already live on this table (DB-07).
  has_one_attached :image
end
