module SpreeChannable
  class ReturnImportJob < ApplicationJob
    queue_as :default

    def perform(*args)
      @client = ::Channable::Client.new
      channable_returns = get_returns
      channable_returns.each &method(:persist_return)
    end

    def get_returns
      limit = 100
      returns = []
      loop do
        return_data = @client.get_returns(offset: returns.size, limit: limit, start_date: (SpreeChannable.configuration.polling_interval * 2).minutes.ago)
        return_data.data.returns.each {|return_data| returns << return_data} if return_data.data.returns.any?

        break if return_data.data.total < limit || (!return_data.success && return_data.response.code != 429)
      end
      returns
    end

    def persist_return(channable_return)
      return if Spree::ReturnAuthorization.exists?(channable_return_id: channable_return.channable_id)
      begin
        SpreeChannable::ReturnImporter.import(channable_return)
      rescue StandardError => e
        Rails.logger.warn "[CHANNABLE] Failed to import return #{channable_return.channable_id}. #{e}"
        @client.return_update(channable_return.channable_id, {status: 'cancelled'}.to_json)
      end
    end

  end
end