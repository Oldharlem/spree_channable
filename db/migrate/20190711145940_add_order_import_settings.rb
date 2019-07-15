class AddOrderImportSettings < ActiveRecord::Migration[5.0]
  def change
    change_table :channable_settings do |t|
      t.integer :polling_interval, default: 30
      t.integer :spree_payment_method_id
      t.boolean :active, default: false
    end
  end
end
