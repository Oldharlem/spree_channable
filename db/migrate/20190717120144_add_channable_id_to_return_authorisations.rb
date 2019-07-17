class AddChannableIdToReturnAuthorisations < ActiveRecord::Migration[5.0]
  def change
    add_column :spree_customer_returns, :channable_return_id, :integer
  end
end
