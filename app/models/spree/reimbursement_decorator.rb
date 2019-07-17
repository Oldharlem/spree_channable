module Spree
  module SpreeChannable
    module ReimbursementDecorator
      def send_reimbursement_email
        super unless order.is_channable_order?
      end

      def reimburse_channable_order
        return unless is_channable_order?

        client = ::Channable::Client.new
        client.return_update(customer_return.channable_return_id, channable_return)
      end

      def channable_return
        {
            status: channable_return_status
        }.to_json
      end

      def channable_return_status
        case reimbursement_status
        when 'reimbursed'
          'accepted'
        when 'errored'
          'cancelled'
        else
          'accepted'
        end
      end

      def self.prepended(base)
        base.state_machine.after_transition to: :reimbursed, do: :reimburse_channable_order
      end
    end
  end
end

Spree::Reimbursement.prepend(Spree::SpreeChannable::ReimbursementDecorator)