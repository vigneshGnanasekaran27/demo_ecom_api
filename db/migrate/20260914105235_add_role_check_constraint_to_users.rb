class AddRoleCheckConstraintToUsers < ActiveRecord::Migration[8.1]
  # The six fixed roles (DECISION-011/012) — no dynamic/DB-driven RBAC.
  VALID_ROLES = %w[customer admin manager warehouse dispatch delivery].freeze

  def change
    add_check_constraint :users,
      "role IN (#{VALID_ROLES.map { |role| "'#{role}'" }.join(', ')})",
      name: "users_role_check"
  end
end
