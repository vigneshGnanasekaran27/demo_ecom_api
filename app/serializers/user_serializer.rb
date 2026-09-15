# Controls exactly what a user record exposes over the API — never the raw
# AR object (BACKEND_RULES.md §5), and never password_digest.
class UserSerializer
  def initialize(user)
    @user = user
  end

  def as_json(*)
    {
      id: user.id,
      email: user.email,
      full_name: user.full_name,
      phone: user.phone,
      role: user.role,
      active: user.active
    }
  end

  private

  attr_reader :user
end
