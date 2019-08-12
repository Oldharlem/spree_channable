module Spree
  module SpreeChannable
    module OrderDecorator

      def channable_client
        @channable_client ||= ::Channable::Client.new
      end

      def deliver_order_confirmation_email
        unless is_channable_order?
          super
        end
      end

      def send_cancel_email
        unless is_channable_order?
          super
        end
      end

      def is_channable_order?
        channable_order_id.present?
      end

      def cancel_channable_order
        return unless is_channable_order?

        channable_client.cancellation_update(channable_order_id)
      end

      def self.prepended(base)
        base.state_machine.after_transition to: :cancelled, do: :cancel_channable_order

        class << base

          def channable_to_order_params(channable_order)
              order_params = {}

              order_params[:channable_order_id] = channable_order.id
              order_params[:channable_channel_order_id] = channable_order.channel_id
              order_params[:channable_channel_name] = channable_order.channel_name
              order_params[:completed_at] = DateTime.parse(channable_order.created)
              order_params[:email] = channable_order.data.shipping.email

              order_params[:bill_address_attributes] = build_address(channable_order.data.billing)
              order_params[:ship_address_attributes] = build_address(channable_order.data.shipping)

              order_params[:shipments_attributes] = build_shipments_attributes(channable_order)
              order_params[:payments_attributes] = build_payments_attributes(channable_order)
              order_params[:line_items_attributes] = build_line_items_attributes(channable_order)

              order_params
          end

          def build_address(address_params)
            {
                firstname: address_params.first_name,
                lastname: address_params.last_name,
                address1: address_params.street,
                address2: [address_params.house_number, address_params.house_number_ext].join(' '),
                city: address_params.city,
                zipcode: address_params.zip_code,
                phone: '0612345678',
                country: {
                    'iso' => address_params.country_code
                }
            }
          end

          def build_shipments_attributes(channable_order)
            [
                {
                    tracking: nil,
                    stock_location: ::SpreeChannable.configuration.stock_location,
                    shipping_method: channable_order.channel_name,
                    inventory_units: channable_order.data.products.flat_map do |item|
                      variant = Spree::Variant.active.find_by_sku!(item.ean)
                      item.quantity.times.map do
                        {
                            variant_id: variant.id
                        }
                      end
                    end
                }
            ]
          end

          def build_payments_attributes(channable_order)
            [
                {
                    amount: channable_order.data.price.total.to_f,
                    state: 'completed',
                    payment_method: ::SpreeChannable.configuration.payment_method
                }
            ]
          end

          def build_line_items_attributes(channable_order)
            channable_order.data.products.map do |item|
              variant = Spree::Variant.active.find_by_sku!(item.ean)
              {
                  variant_id: variant.id,
                  quantity: item.quantity,
                  price: item.price.to_f
              }
            end.compact
          end


          def build_adjustments_attributes(channable_order)
            raise 'Not implemented'
            [
                {
                    label: 'Channable Discount',
                    amount: -(channable_order['discount'].abs.to_f)
                }
            ]
          end

        end
      end
    end
  end
end

Spree::Order.prepend(Spree::SpreeChannable::OrderDecorator)

