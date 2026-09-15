# Public read (products_controller.rb doesn't even call Pundit — read is
# always allowed), manager-only write (PROJECT_CONTEXT.md §4). Also gates
# product image management (ProductImagesController authorizes against the
# parent product's update? — there's no separate ProductImagePolicy).
class ProductPolicy < ApplicationPolicy
  def index? = true
  def show? = true
  def create? = manager?
  def update? = manager?
  def deactivate? = manager?

  private

  def manager?
    user&.manager? || false
  end
end
