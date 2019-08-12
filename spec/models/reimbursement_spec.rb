require 'spree/testing_support/order_walkthrough'

RSpec.describe Spree::Reimbursement, type: :model do
  describe 'with channable order' do

    let!(:reimbursement) { create(:reimbursement) }

    before do
      reimbursement.order.update(channable_order_id: '123789')
      reimbursement.customer_return.update(channable_return_id: '789123')
    end

    it 'does not deliver reimbursement confirmation mails' do
      expect(Spree::ReimbursementMailer).not_to receive(:send_reimbursement_email).with(reimbursement.id)
      reimbursement.send_reimbursement_email
    end

    it 'produces a channable return json with a valid status' do
      result = JSON.parse(reimbursement.channable_return)
      expect(result).to have_key('status')
      expect(result['status']).to eq('accepted')
    end

    it 'does reimburse a channable order' do
      allow_any_instance_of(Channable::Client).to receive(:return_update).with(reimbursement.customer_return.channable_return_id, reimbursement.channable_return).and_return('method call ok')
      expect(reimbursement.reimburse_channable_order).to eq('method call ok')
    end

    it 'has a channable return status of accepted' do
      expect(reimbursement.channable_return_status).to eq('accepted')
    end
  end

  describe 'without channable order' do
    let!(:reimbursement) { create(:reimbursement) }

    it 'does not deliver reimbursement confirmation mails' do
      message_delivery = instance_double(ActionMailer::MessageDelivery)
      expect(Spree::ReimbursementMailer).to receive(:reimbursement_email).with(reimbursement.id).and_return(message_delivery)
      allow(message_delivery).to receive(:deliver_later)
      reimbursement.send_reimbursement_email
    end

    it 'does reimburse a channable order' do
      expect(reimbursement.reimburse_channable_order).to eq(nil)
    end

  end

end
