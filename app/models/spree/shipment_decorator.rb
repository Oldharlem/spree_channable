module Spree
  module SpreeChannable
    module ShipmentDecorator

      def self.prepended(base)
        base.state_machine.after_transition to: :shipped, do: :send_shipment_update
      end

      def send_shipment_update
        return unless order.is_channable_order?

        client = ::Channable::Client.new
        client.shipment_update(order.channable_order_id, channable_shipment)
      end

      def channable_shipment
        {
            tracking_code: tracking,
            tracking_url: tracking_url,
            transporter: shipping_method.channable_transporter_code
        }.to_json
      end

    end
  end
end

Spree::Shipment.prepend(Spree::SpreeChannable::ShipmentDecorator)