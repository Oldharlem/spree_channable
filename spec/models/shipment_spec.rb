RSpec.describe Spree::Shipment, type: :model do

  describe 'channable shipment' do

    let(:shipping_method) {create(:free_shipping_method, name: 'Test Air', channable_transporter_code: 'test_trans', tracking_url: 'https://example_tracking.com/track/:tracking')}
    let(:order) {create(:order_ready_to_ship, channable_order_id: '123789')}
    let(:shipment) do
      s = order.shipments.first
      s.selected_shipping_rate.update(shipping_method: shipping_method)
      s.update_attributes(tracking: 'Sgw3RNa2ivCI29')
      s
    end

    it 'has a shipping method' do
      expect(shipment.shipping_method.name).to eq('Test Air')
    end

    it 'sends a shipping update to channable after shipping' do
      expect(shipment).to receive(:send_shipment_update)
      shipment.ship!
    end

    it 'returns a channable response when send_shipment_update is called' do
      response = Channable::Response
      allow_any_instance_of(Channable::Client).to receive(:shipment_update).and_return(response)
      expect(shipment.send_shipment_update).to eq(response)
    end

    it 'returns a channable shipment update JSON' do
      expect(shipment.channable_shipment).to be_kind_of(String)
    end

    describe 'channable shipment json' do
      it 'has a tracking code' do
        result = JSON.parse shipment.channable_shipment
        expect(result['tracking_code']).to eq('Sgw3RNa2ivCI29')
      end

      it 'has a tracking url' do
        result = JSON.parse shipment.channable_shipment
        expect(result['tracking_url']).to eq('https://example_tracking.com/track/Sgw3RNa2ivCI29')
      end

      it 'has a transporter' do
        result = JSON.parse shipment.channable_shipment
        expect(result['transporter']).to eq('test_trans')
      end
    end

  end

  describe 'regular shipment' do
    let(:shipping_method) {create(:free_shipping_method, name: 'Test Air', channable_transporter_code: 'test_trans', tracking_url: 'https://example_tracking.com/track/:tracking')}
    let(:order) {create(:order_ready_to_ship)}
    let(:shipment) do
      s = order.shipments.first
      s.selected_shipping_rate.update(shipping_method: shipping_method)
      s.update_attributes(tracking: 'Sgw3RNa2ivCI29')
      s
    end

    it 'does not return a channable response when send_shipment_update is called' do
      expect(shipment.send_shipment_update).to eq(nil)
    end
  end

end
