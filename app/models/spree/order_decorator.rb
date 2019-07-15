module Spree
  module SpreeChannable
    module OrderDecorator

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

        client = ::Channable::Client.new
        client.cancellation_update(channable_order_id)
      end

# {
#   "order": {
#     "channel_id": "123",
#     "channel_name": "bol",
#     "created": "2017-08-02T14:31:48",
#     "data": {
#       "billing": {
#         "address1": "Billingstraat 1",
#         "address2": "Onder de brievanbus huisnummer 1 extra adres info",
#         "address_supplement": "Onder de brievanbus huisnummer 1 extra adres info",
#         "city": "Amsterdam",
#         "company": "Bol.com",
#         "country_code": "NL",
#         "email": "dontemail@me.net",
#         "first_name": "Jans",
#         "house_number": 1,
#         "house_number_ext": "",
#         "last_name": "Janssen",
#         "middle_name": "",
#         "region": "",
#         "street": "Billingstraat",
#         "zip_code": "5000 ZZ"
#       },
#       "customer": {
#         "company": "Bol.com",
#         "email": "dontemail@me.net",
#         "first_name": "Jans",
#         "gender": "male",
#         "last_name": "Janssen",
#         "middle_name": "",
#         "mobile": "",
#         "phone": "0201234567"
#       },
#       "extra": {
#         "comment": "Bol.com order id: 123",
#         "memo": "Order from Channable \n Bol.com order id: 123\n Customer receipt: https:\/\/www.bol.com\/sdd\/orders\/downloadallpackageslips.html"
#       },
#       "price": {
#         "commission": 1.5,
#         "currency": "EUR",
#         "payment_method": "bol",
#         "shipping": 0,
#         "subtotal": 123.45,
#         "total": 123.45,
#         "transaction_fee": 0
#       },
#       "products": [
#         {
#           "commission": 1.5,
#           "delivery_period": "2017-08-02+02:00",
#           "ean": "9789062387410",
#           "id": "11693020",
#           "price": 61.725,
#           "quantity": 2,
#           "reference_code": "123",
#           "shipping": 0,
#           "title": "Harry Potter"
#         }
#       ],
#       "shipping": {
#         "address1": "Shipmentstraat 42 bis",
#         "address2": "",
#         "address_supplement": "3 hoog achter extra adres info",
#         "city": "Amsterdam",
#         "company": "The Company",
#         "country_code": "NL",
#         "email": "nospam4me@myaccount.com",
#         "first_name": "Jan",
#         "house_number": 42,
#         "house_number_ext": "bis",
#         "last_name": "Janssen",
#         "middle_name": "",
#         "region": "",
#         "street": "Shipmentstraat",
#         "zip_code": "1000 AA"
#       }
#     },
#     "error": false,
#     "fulfillment": {},
#     "id": 299623,
#     "modified": "2017-08-10T18:08:13.699449",
#     "platform_id": "299623",
#     "platform_name": "channable",
#     "project_id": 6496,
#     "status_paid": "paid",  # This is always paid, because the marketplace handles payments
#     "status_shipped": "shipped"
#   },
#   "events": [
#     {
#       "created": "2016-10-20T10:55:08.507355",
#       "id": 1234545,
#       "message": "Sent shipment update to Amazon",
#       "modified": "2016-10-20T10:55:08.507378",
#       "order_id": 299623,
#       "project_id": 91919,
#       "status": "info"
#     },
#     {
#       "created": "2016-10-20T10:54:53.074700",
#       "id": 2370337,
#       "message": "Changed shipping status: not_shipped -> shipped",
#       "modified": "2016-10-20T10:54:53.074705",
#       "order_id": 299623,
#       "project_id": 91919,
#       "status": "info"
#     },
#     {
#       "created": "2016-10-19T10:54:15.008544",
#       "id": 1407404,
#       "message": "Channable order processed: 299623",
#       "modified": "2016-10-19T10:54:15.008551",
#       "order_id": 299623,
#       "project_id": 91919,
#       "status": "info"
#     }
#   ]
# }
      def self.prepended(base)

        base.validates :channable_order_id, uniqueness: true

        base.state_machine.after_transition to: :cancelled, do: :cancel_channable_order

        class << base

          def channable_to_order_params(channable_order)
            order_params = {}

            channable_order.data.products.each do |channable_product|
              channable_product.ean = Spree::Variant.active.sample.sku
            end

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

            # order_params[:adjustments_attributes] = build_adjustments_attributes(channable_order)

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

#     "shipments_attributes": [
#       {
#         "tracking": "track track track",
#         "stock_location": "default",
#         "cost": 11,
#         "shipping_method": "UPS Ground (USD)",
#         "inventory_units": [
#           { "variant_id": "1" },
#           { "variant_id": "2" },
#           { "variant_id": "2" },
#           { "variant_id": "2" },
#           { "variant_id": "2" },
#           { "variant_id": "3" },
#           { "variant_id": "4" },
#           { "variant_id": "5" }
#         ]
#       }
#     ],
          def build_shipments_attributes(channable_order)
            [
                {
                    tracking: nil,
                    stock_location: ::SpreeChannable.configuration.stock_location,
                    shipping_method: channable_order.channel_name,
                    inventory_units: channable_order.data.products.map do |item|
                      item.quantity.times.map do
                        {
                            sku: item.ean
                        }
                      end
                    end.flatten
                }
            ]
          end

#     "payments_attributes": [
#       {
#         "number": "REGE345546FDF",
#         "state": "completed",
#         "amount": 480.90,
#         "payment_method": "Authorize.Net"
#       },
#       {
#         "number": "ERERGREG43534DF",
#         "state": "void",
#         "amount": 46.95,
#         "payment_method": "Authorize.Net"
#       }
#     ],
          def build_payments_attributes(channable_order)
            [
                {
                    amount: channable_order.data.price.total.to_f,
                    state: 'completed',
                    payment_method: ::SpreeChannable.configuration.payment_method
                }
            ]
          end

#     "line_items_attributes": {
#       "0": {
#         "variant_id": "1",
#         "quantity": 1,
#         "price": 50
#       },
#       "3": {
#         "variant_id": "2",
#         "quantity": 4,
#         "price": 60
#       },
#     },
#
          def build_line_items_attributes(channable_order)
            channable_order.data.products.map do |item|
              variant = Spree::Variant.active.find_by_sku(item.ean)
              next if variant.blank?
              {
                  variant_id: variant.id,
                  quantity: item.quantity,
                  price: item.price.to_f
              }
            end.compact
          end

# "adjustments_attributes": [
#       {
#         "label": "tax",
#         "amount": 0
#       },
#       {
#         "label": "something",
#         "amount": 17.9
#       }
#     ],
          def build_adjustments_attributes(channable_order)
            raise 'Not implemented'
            [
                {
                    label: 'Channable Discount',
                    amount: -(channable_order['discount'].to_f.abs)
                }
            ]
          end

        end
      end
    end
  end
end

Spree::Order.prepend(Spree::SpreeChannable::OrderDecorator)

