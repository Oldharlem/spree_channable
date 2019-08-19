module Spree
  module SpreeChannable
    module VariantDecorator

      def self.same_product_colors(variant)
        joins(option_values: :translations).where(spree_option_value_translations: {presentation: variant.option_value('color')}, product_id: variant.product_id).includes(:default_price, option_values: :option_type)
      end

      def to_channable_feed_entry
        return nil if price.blank?

        Nokogiri::XML::Builder.new do |xml|
          xml.variant {
            xml.id id
            xml.product_id product.id
            xml.title "#{product.name}"
            xml.description ActionController::Base.helpers.strip_tags(product.normalized_description)
            xml.link URI.join(::SpreeChannable.configuration.host, "/#{::SpreeChannable.configuration.url_prefix}/" + product.slug).to_s
            (xml.image_link URI.join(::SpreeChannable.configuration.image_host, get_images.first.attachment.url(:large)).to_s) unless get_images.empty?
            xml.condition product.property('product_condition') || ::SpreeChannable.configuration.product_condition

            xml.images do
              get_images.each do |image|
                xml.image URI.join(::SpreeChannable.configuration.image_host, image.attachment.url(:large)).to_s
              end
            end

            xml.availability can_supply?
            xml.stock total_on_hand
            xml.price price
            xml.sale_price respond_to?(:sale_price) ? (sale_price || price) : price

            xml.gtin sku
            xml.mpn sku
            xml.sku sku

            xml.brand product.property('brand') || ::SpreeChannable.configuration.brand

            xml.categories do
              product.taxons.each do |taxon|
                xml.category taxon.self_and_ancestors.collect(&:name).join('|')
              end
            end

            xml.currency Spree::Config.currency
            xml.locale I18n.default_locale

            option_values.each do |option_value|
              xml.send(option_value.option_type.name, option_value.presentation)
            end

            # Property fields

            xml.gender product.property('gender') || 'Not set'
            xml.delivery_period product.property('delivery_period') || ::SpreeChannable.configuration.delivery_period
            xml.material product.property('material') || 'Not set'
          }
        end.to_xml
      end

      def get_images
        images = []
        if ::SpreeChannable.configuration.use_variant_images
          if self.class.respond_to?(:same_product_colors)
            images = self.class.same_product_colors(self).flat_map(&:images)
          else
            self.images
          end
        else
          self.product.images
        end

        if images.any?
          images
        else
          self.product.images
        end
      end

    end
  end
end

Spree::Variant.prepend(Spree::SpreeChannable::VariantDecorator)