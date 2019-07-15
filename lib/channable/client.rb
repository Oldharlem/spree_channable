require 'httparty'

module Channable
  class Client
    include ::HTTParty

    def initialize
      self.class.base_uri "https://api.channable.com/v1/companies/#{SpreeChannable.configuration.company_id}/projects/#{SpreeChannable.configuration.project_id}"
      self.class.headers 'Authorization' => "Bearer #{SpreeChannable.configuration.channable_api_key}"
      self.class.headers 'Content-Type' => 'application/json'
    end

    def get_orders(start_date: 1.day.ago, offset: 0, limit: 100)
      Channable::Response.new(self.class.get('/orders', query: {
          limit: limit,
          start_date: start_date.strftime('%Y-%m-%d'),
          offset: offset
      }))
    end

    def shipment_update(order_id, shipment)
      Channable::Response.new(self.class.post("/orders/#{order_id}/shipment", body: shipment))
    end

    def cancellation_update(order_id)
      Channable::Response.new(self.class.post("/orders/#{order_id}/cancel"))
    end

  end
end