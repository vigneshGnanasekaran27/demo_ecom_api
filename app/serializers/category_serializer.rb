class CategorySerializer
  def initialize(category)
    @category = category
  end

  def as_json(*)
    {
      id: category.id,
      name: category.name,
      slug: category.slug,
      parent_id: category.parent_id,
      position: category.position
    }
  end

  private

  attr_reader :category
end
