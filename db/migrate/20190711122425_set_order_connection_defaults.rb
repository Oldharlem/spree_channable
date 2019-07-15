class SetOrderConnectionDefaults < ActiveRecord::Migration[5.0]
  def change
    add_column :channable_settings, :spree_stock_location_id, :integer
  end
end
