class AddDefaultValueToTwoFactor < ActiveRecord::Migration[6.0]
  def change
    change_column :users, :two_factor_enabled, :boolean, default: false
  end
end
