module Spree
  module SpreeChannable
    module ReimbursementDecorator
      def send_reimbursement_email
        super unless order.is_channable_order?
      end
    end
  end
end

Spree::Reimbursement.prepend(Spree::SpreeChannable::ReimbursementDecorator)