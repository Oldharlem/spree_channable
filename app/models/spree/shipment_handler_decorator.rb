module Spree
  module SpreeChannable
    module ShipmentHandlerDecorator
      def send_shipped_email
        super unless @shipment.order.is_channable_order?
      end
    end
  end
end

Spree::ShipmentHandler.prepend(Spree::SpreeChannable::ShipmentHandlerDecorator)