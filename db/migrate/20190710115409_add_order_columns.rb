class AddOrderColumns < ActiveRecord::Migration[5.0]
  def change
    change_table :spree_orders do |t|
      t.integer :channable_order_id
      t.string :channable_channel_order_id
      t.string :channable_channel_name
    end
  end
end
