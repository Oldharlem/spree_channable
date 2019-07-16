module SpreeChannable
  class OrderImportJob < ApplicationJob
    queue_as :default

    def perform(*args)
      @client = ::Channable::Client.new
      channable_orders = get_orders
      orders_attributes = channable_orders.map {|channable_order| parse_order(channable_order)}
      orders_attributes.each &method(:persist_order)
    end

    def get_orders
      limit = 100
      orders = []
      loop do
        order_data = client.get_orders(offset: orders.size, limit: limit, start_date: (SpreeChannable.configuration.polling_interval * 2).minutes.ago)
        order_data.data.orders.each {|order| orders << order} if order_data.data.orders.any?

        break if order_data.data.total < limit || (!order_data.success && order_data.response.code != 429)
      end
      orders
    end

    def parse_order(channable_order)
      Spree::Order.channable_to_order_params(channable_order)
    end

    def persist_order(order_attributes)
      return if Spree::Order.exists?(channable_order_id: order_attributes[:channable_order_id])
      begin
        order = SpreeChannable::OrderImporter.import(nil, order_attributes)
      rescue StandardError => e
        Rails.logger.warn "[CHANNABLE] Failed to import order #{order_attributes[:channable_order_id]}. #{e}"
        @client.cancellation_update(order_attributes[:channable_order_id])
      end
      order
    end

    def cancel_order(order_id)
      @client.cancellation_update(order_id)
    end

  end
end