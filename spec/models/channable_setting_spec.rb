RSpec.describe ::ChannableSetting, type: :model do

  describe 'relations' do
    subject {build_stubbed(:channable_setting)}

    it 'has a stock location' do
      expect(subject.stock_location).to be_a(Spree::StockLocation)
    end

    it 'has a payment method' do
      expect(subject.payment_method).to be_a(Spree::PaymentMethod)
    end
  end

  describe 'product conditions' do
    it 'can be New' do
      subject = build(:channable_setting, product_condition: 'New')
      expect(subject.valid?).to be_truthy
    end

    it 'cannot be damaged' do
      subject = build(:channable_setting, product_condition: 'Damaged')
      expect(subject.valid?).to be_falsey
    end
  end

end
