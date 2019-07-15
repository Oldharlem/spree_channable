class ChannableSetting < ApplicationRecord

  belongs_to :stock_location, foreign_key: 'spree_stock_location_id', class_name: 'Spree::StockLocation'
  belongs_to :payment_method, foreign_key: 'spree_payment_method_id', class_name: 'Spree::PaymentMethod'

  PRODUCT_CONDITIONS = ['New', 'Used']

  after_save :update_crontab, if: -> {saved_change_to_polling_interval?}

  def update_crontab
    system 'whenever --update-crontab'
  end

end
