# Public read (categories_controller.rb doesn't even call Pundit — read is
# always allowed), manager-only write (PROJECT_CONTEXT.md §4).
class CategoryPolicy < ApplicationPolicy
  def index? = true
  def show? = true
  def create? = manager?
  def update? = manager?
  def destroy? = manager?

  private

  def manager?
    user&.manager? || false
  end
end
