class AddChannableFieldsToShippingMethods < ActiveRecord::Migration[5.0]
  def change
    change_table :spree_shipping_methods do |t|
      t.string :channable_channel_name
      t.string :channable_transporter_code
    end
  end
end
