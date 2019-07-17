module SpreeChannable
  class ReturnImporter


    # {
    #             "status": "new",
    #             "channel_name": "bol",
    #             "channel_id": "61284922",
    #             "channable_id": 151,
    #             "data": {
    #                 "item": {
    #                     "id": "11694321",
    #                     "order_id": "4522232111",
    #                     "gtin": "0884500642113",
    #                     "title": "Nike Air Force 1 Winter Premium GS Flax Pack",
    #                     "quantity": 1,
    #                     "reason": "Anders, namelijk:",
    #                     "comment": "De schoenen vielen te groot."
    #                 },
    #                 "customer": {
    #                     "gender": "male",
    #                     "first_name": "Jans",
    #                     "last_name": "Van Janssen",
    #                     "email": "2ixee2337ca74m23423uu@verkopen.bol.com"
    #                 },
    #                 "address": {
    #                     "first_name": "Jans",
    #                     "last_name": "Van Janssen",
    #                     "email": "2ixee2337ca74m23423uu@verkopen.bol.com",
    #                     "street": "Teststraat",
    #                     "house_number": 12,
    #                     "address1": "Teststraat 12",
    #                     "adderss2": "",
    #                     "city": "Utrecht",
    #                     "country_code": "NL",
    #                     "zip_code": "1234 XZ"
    #                 }
    #             }
    #         }
    def self.import(return_data)
      order = Spree::Order.find_by_channable_order_id(return_data.data.item.order_id)

      return_reason_id = Spree::ReturnAuthorizationReason.first.id
      inventory_unit = order.line_items.detect {|li| li.variant.sku == return_data.data.item.gtin}&.inventory_units&.first


      if order && inventory_unit
        return_authorization = Spree::ReturnAuthorization.create!(
            order_id: order.id,
            stock_location: ::SpreeChannable.configuration.stock_location,
            return_authorization_reason_id: return_reason_id
        )
        Spree::CustomerReturn.create(
            stock_location: ::SpreeChannable.configuration.stock_location,
            channable_order_id: return_data.channable_id,
            return_items_attributes: {
                return_authorization_id: return_authorization.id, inventory_unit_id: inventory_unit.id
            })
      end
    end

  end
end