require 'spree/testing_support/order_walkthrough'

RSpec.describe Spree::ShipmentHandler, type: :model do

  describe 'channable shipment' do
    let(:order) {create(:order_ready_to_ship, channable_order_id: '123789')}
    let(:shipment) {order.shipments.first}

    it 'does not send a shipping confirmation' do
      message_delivery = instance_double(ActionMailer::MessageDelivery)
      expect(Spree::ShipmentMailer).not_to receive(:shipped_email)
      allow(message_delivery).to receive(:deliver_later)
      shipment.ship!
    end
  end

  describe 'regular shipment' do
    let(:order) {create(:order_ready_to_ship)}
    let(:shipment) {order.shipments.first}

    it 'does send a shipping confirmation' do
      message_delivery = instance_double(ActionMailer::MessageDelivery)
      expect(Spree::ShipmentMailer).to receive(:shipped_email).with(shipment.id).and_return(message_delivery)
      allow(message_delivery).to receive(:deliver_later)
      shipment.ship!
    end
  end

end
