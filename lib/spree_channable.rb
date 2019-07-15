require 'spree_core'
require 'spree_extension'
require 'spree_channable/engine'
require 'spree_channable/version'
require 'spree_channable/order_importer'

require 'channable/client'
require 'channable/response'

require 'whenever'

module SpreeChannable

  class << self
    def configuration
      Configuration.new
    end
  end

  class Configuration
    ATTR_LIST = [:host, :url_prefix, :image_host, :product_condition, :brand, :delivery_period, :use_variant_images, :channable_api_key, :company_id, :project_id, :stock_location, :payment_method, :polling_interval, :active]

    ATTR_LIST.each do |a|
      define_method a do
        setting_model.try(a)
      end
    end

    private

    def setting_model
      ::ChannableSetting.last
    end
  end

end