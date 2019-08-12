class ChannableSetting < ActiveRecord::Base

  belongs_to :stock_location, foreign_key: 'spree_stock_location_id', class_name: 'Spree::StockLocation'
  belongs_to :payment_method, foreign_key: 'spree_payment_method_id', class_name: 'Spree::PaymentMethod'

  PRODUCT_CONDITIONS = ['New', 'Used']

  validates_inclusion_of :product_condition, in: PRODUCT_CONDITIONS

end
