require 'parallel'

module Spree
  module SpreeChannable
    module ProductDecorator

      def self.collection_to_channable_variant_xml(products)
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.feed(xmlns: 'http://www.w3.org/2005/Atom') do
            xml.title 'Channable variant feed'
            xml.link(rel: 'self', href: SpreeChannable.configuration.host)
            xml.updated DateTime.now.strftime('%Y-%m-%dT%H:%M:%S%z')

            Parallel.map(products) {|product| product.to_channable_variant_xml}.each do |products_xml|
              products_xml.each do |variant_xml|
                xml.parent << Nokogiri::XML(variant_xml).at('product')
              end
            end

          end
        end

        builder.to_xml
      end

      def self.collection_to_channable_product_xml(products)
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.title 'Channable product feed'
          xml.link(rel: 'self', href: SpreeChannable.configuration.host)
          xml.updated DateTime.now.strftime('%Y-%m-%dT%H:%M:%S%z')

          Parallel.map(products) {|product| product.to_channable_product_xml}.each do |product_xml|
            product_xml.each do |variant_xml|
              xml.parent << Nokogiri::XML(variant_xml).at('product')
            end
          end
        end

        builder.to_xml
      end

      def to_channable_variant_xml
        variants.active.map do |variant|
          variant.to_channable_feed_entry
        end
      end

      def to_channable_product_xml

      end

    end
  end
end

Spree::Product.prepend(Spree::SpreeChannable::ProductDecorator)