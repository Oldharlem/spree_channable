require 'parallel'

module Spree
  module SpreeChannable
    module ProductDecorator
      def self.prepended(base)
        class << base

          def to_channable_variant_xml(products)
            builder = Nokogiri::XML::Builder.new do |xml|
              xml.feed(xmlns: 'http://www.w3.org/2005/Atom') do
                xml.title 'Channable variant feed'
                xml.link(rel: 'self', href: ::SpreeChannable.configuration.host)
                xml.updated DateTime.now.strftime('%Y-%m-%dT%H:%M:%S%z')

                xml.variants do
                  products.map { |product| product.to_channable_variant_xml }.each do |variants_xml|
                    variants_xml.each do |variant_xml|
                      xml.parent << Nokogiri::XML(variant_xml).at('variant')
                    end
                  end
                end


              end
            end

            builder.to_xml
          end

          def to_channable_product_xml(products)
            builder = Nokogiri::XML::Builder.new do |xml|
              xml.feed(xmlns: 'http://www.w3.org/2005/Atom') do
                xml.title 'Channable product feed'
                xml.link(rel: 'self', href: ::SpreeChannable.configuration.host)
                xml.updated DateTime.now.strftime('%Y-%m-%dT%H:%M:%S%z')

                xml.products do
                  products.map { |product| product.to_channable_product_xml }.each do |product_xml|
                    xml.parent << Nokogiri::XML(product_xml).at('product')
                  end
                end

              end
            end
            builder.to_xml
          end
        end
      end


      def to_channable_variant_xml
        (variants.any? ? variants : variants_including_master).active.uniq.map do |variant|
          variant.to_channable_feed_entry
        end
      end

      def to_channable_product_xml
        Rails.cache.fetch(['product-channable-feed-entry', self]) do
          Nokogiri::XML::Builder.new do |xml|
            xml.product do
              xml.id id
              xml.master_id master_id
              xml.title "#{name}"
              xml.description ActionController::Base.helpers.strip_tags(normalized_description)
              xml.link URI.join(::SpreeChannable.configuration.host, "/#{::SpreeChannable.configuration.url_prefix}/" + "#{slug}").to_s
              (xml.image_link URI.join(::SpreeChannable.configuration.image_host, images.first.attachment.url(:large)).to_s) if images.any?
              xml.condition property('product_condition') || ::SpreeChannable.configuration.product_condition

              xml.images do
                images.each do |image|
                  xml.image URI.join(::SpreeChannable.configuration.image_host, image.attachment.url(:large)).to_s
                end
              end

              xml.price price

              xml.brand property('brand') || ::SpreeChannable.configuration.brand

              xml.categories do
                taxons.each do |taxon|
                  xml.category taxon.self_and_ancestors.collect(&:name).join('|')
                end
              end

              xml.currency Spree::Config.currency
              xml.locale I18n.default_locale

              # Property fields

              xml.gender property('gender') || 'Not set'
              xml.delivery_period property('delivery_period') || ::SpreeChannable.configuration.delivery_period
              xml.material property('material') || 'Not set'

              xml.variants do
                (variants.any? ? variants : variants_including_master).each do |variant|
                  xml.variant do
                    xml.id variant.id
                    xml.product_id id
                    xml.options_text variant.options_text
                    (xml.image_link URI.join(::SpreeChannable.configuration.image_host, variant.get_images.first.attachment.url(:large)).to_s) unless variant.get_images.empty?
                    xml.images do
                      variant.get_images.each do |image|
                        xml.image URI.join(::SpreeChannable.configuration.image_host, image.attachment.url(:large)).to_s
                      end
                    end

                    xml.availability variant.can_supply?
                    xml.stock variant.total_on_hand
                    xml.price variant.price
                    xml.sale_price variant.respond_to?(:sale_price) ? (variant.sale_price || variant.price) : variant.price

                    xml.sku variant.sku

                    xml.currency Spree::Config.currency
                    xml.locale I18n.default_locale

                    variant.option_values.each do |option_value|
                      xml.send(option_value.option_type.name, option_value.presentation)
                    end
                  end
                end
              end

            end
          end.to_xml
        end
      end

      def normalized_description
        if description.blank? || description.length < 3
          name
        else
          description
        end
      end

    end
  end
end

Spree::Product.prepend(Spree::SpreeChannable::ProductDecorator)
