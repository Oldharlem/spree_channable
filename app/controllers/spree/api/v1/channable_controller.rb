class Spree::Api::V1::ChannableController < Spree::Api::BaseController

  before_action :get_products, only: [:variant_feed, :product_feed]

  def variant_feed
    headers["Content-Type"] = 'application/atom+xml; charset=utf-8'
    render plain: Spree::Product.collection_to_channable_variant_xml(@products)
  end

  def product_feed
    headers["Content-Type"] = 'application/atom+xml; charset=utf-8'
    render plain: Spree::Product.collection_to_channable_product_xml(@products)
  end

  private

  def get_products
    @products = Spree::Product.active.includes([:option_types, :taxons, product_properties: :property, variants: [{option_values: :option_type}, :default_price, :images], master: [{option_values: :option_type}, :default_price, :images]]).first(20)
  end

end