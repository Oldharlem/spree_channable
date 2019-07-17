module SpreeChannable
  class OrderImportJob < ApplicationJob
    queue_as :default

    def perform(*args)
      @client = ::Channable::Client.new
      channable_orders = get_orders
      channable_orders.each &method(:persist_order)
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

    def persist_order(channable_order)
      return if Spree::Order.exists?(channable_order_id: channable_order.id)
      begin
        order_attributes = Spree::Order.channable_to_order_params(channable_order)
        SpreeChannable::OrderImporter.import(nil, order_attributes)
      rescue StandardError => e
        Rails.logger.warn "[CHANNABLE] Failed to import order #{channable_order.id}. #{e}"
        @client.cancellation_update(channable_order.id)
      end
    end

  end
end