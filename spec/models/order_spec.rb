require 'spree/testing_support/order_walkthrough'

RSpec.describe Spree::Order, type: :model do

  context 'regular spree order' do
    before(:each) do
      @order = OrderWalkthrough.up_to(:complete).tap {|o| o.update(confirmation_delivered: false)}
    end

    it 'does deliver order confirmation mails' do
      message_delivery = instance_double(ActionMailer::MessageDelivery)
      expect(Spree::OrderMailer).to receive(:confirm_email).with(@order.id).and_return(message_delivery)
      allow(message_delivery).to receive(:deliver_later)
      @order.finalize!
      expect(@order.confirmation_delivered?).to be_truthy
    end

    it 'does deliver cancel mails' do
      message_delivery = instance_double(ActionMailer::MessageDelivery)
      expect(Spree::OrderMailer).to receive(:cancel_email).with(@order.id).and_return(message_delivery)
      allow(message_delivery).to receive(:deliver_later)
      @order.cancel!
      expect(@order.state).to eq('canceled')
    end

    it 'is not a channable order' do
      expect(@order.is_channable_order?).to be_falsey
    end

    it 'does not cancel a channable order' do
      expect(@order.cancel_channable_order).to be_nil
    end
  end

  context 'channable order' do
    before(:each) do
      @order = OrderWalkthrough.up_to(:complete).tap {|o| o.update_attributes(confirmation_delivered: false, channable_order_id: '345345')}
    end

    it 'does not deliver order confirmation mails' do
      expect(Spree::OrderMailer).not_to receive(:confirm_email).with(@order.id)
      @order.finalize!
      expect(@order.confirmation_delivered?).to be_falsey
    end

    it 'does not deliver cancel mails' do
      expect(Spree::OrderMailer).not_to receive(:cancel_email).with(@order.id)
      @order.cancel!
      expect(@order.state).to eq('canceled')
    end

    it 'is a channable order' do
      expect(@order.is_channable_order?).to be_truthy
    end

    it 'does cancel a channable order' do
      allow_any_instance_of(Channable::Client).to receive(:cancellation_update).and_return('cancellation update ok')
      expect(@order.cancel_channable_order).to eq('cancellation update ok')
    end
  end

  describe 'importing channable orders' do
    context 'with valid import json' do
      let!(:order_response) do
        JSON.parse(File.read('spec/fixtures/valid_channable_order.json'), object_class: OpenStruct).order
      end
      let!(:product) do
        create(:product_in_stock, sku: '9789062387410', price: 61.72, name: 'Harry Potter')
      end

      subject(:hash) {Spree::Order.channable_to_order_params(order_response)}

      it 'generates a valid hash' do
        expect(subject).to be_kind_of(Hash)
      end

      context 'after generating a hash' do
        it {should have_key(:channable_order_id)}
        it {should have_key(:email)}
        it {should have_key(:completed_at)}
        it {should have_key(:bill_address_attributes)}
        it {should have_key(:ship_address_attributes)}
        it {should have_key(:shipments_attributes)}
        it {should have_key(:payments_attributes)}
        it {should have_key(:line_items_attributes)}
        it {should have_key(:channable_channel_name)}
        it {should have_key(:channable_channel_order_id)}

        it 'should have line items' do
          expect(subject[:line_items_attributes].length).to be > 0
        end

        context 'ship address' do
          subject {hash[:ship_address_attributes]}

          it {should have_key(:firstname)}
          it {should have_key(:lastname)}
          it {should have_key(:address1)}
          it {should have_key(:address2)}
          it {should have_key(:city)}
          it {should have_key(:zipcode)}
          it {should have_key(:phone)}
          it 'should have a country iso code' do
            expect(subject[:country]).to have_key('iso')
          end
        end

        context 'bill address' do
          subject {hash[:bill_address_attributes]}

          it {should have_key(:firstname)}
          it {should have_key(:lastname)}
          it {should have_key(:address1)}
          it {should have_key(:address2)}
          it {should have_key(:city)}
          it {should have_key(:zipcode)}
          it {should have_key(:phone)}
          it 'should have a country iso code' do
            expect(subject[:country]).to have_key('iso')
          end
        end

        context 'shipments' do
          subject {hash[:shipments_attributes].first}

          it {should have_key(:tracking)}
          it {should have_key(:stock_location)}
          it {should have_key(:shipping_method)}
          it 'should have inventory units' do
            expect(subject[:inventory_units].length).to be > 0
          end

          it 'should have an inventory unit matching the variant' do
            expect(subject[:inventory_units].first[:variant_id]).to eq(product.master.id)
          end
        end

        context 'payments' do
          subject {hash[:payments_attributes].first}

          it {should have_key(:amount)}
          it {should have_key(:state)}
          it {should have_key(:payment_method)}

          it 'should have an amount matching the order total' do
            expect(subject[:amount]).to eq(order_response.data.price.total.to_f)
          end
        end

        context 'line items' do
          subject {hash[:line_items_attributes]}

          it 'should have the correct number of line items' do
            expect(subject.length).to eq(order_response.data.products.length)
          end

          it 'should have a line item matching the json' do
            expect(subject.first[:variant_id]).to eq(product.master.id)
            expect(subject.first[:quantity]).to be(order_response.data.products.first.quantity)
            expect(subject.first[:price]).to be(order_response.data.products.first.price.to_f)
          end
        end
      end
    end

    context 'with invalid import json' do
      let!(:order_response) do
        JSON.parse(File.read('spec/fixtures/invalid_channable_order.json'), object_class: OpenStruct).order
      end

      it 'raises RecordNotFound' do
        expect {Spree::Order.channable_to_order_params(order_response)}.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end
  end

end
