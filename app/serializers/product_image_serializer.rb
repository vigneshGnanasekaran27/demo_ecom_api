class ProductImageSerializer
  def initialize(image)
    @image = image
  end

  def as_json(*)
    {
      id: image.id,
      position: image.position,
      alt_text: image.alt_text,
      url: image.image.attached? ? image.image.blob.url : nil
    }
  end

  private

  attr_reader :image
end
