class CreateChannableSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :channable_settings do |t|

      t.string :host
      t.string :url_prefix
      t.string :image_host
      t.string :product_condition
      t.string :brand
      t.string :delivery_period
      t.boolean :use_variant_images

      t.timestamps
    end
  end
end
