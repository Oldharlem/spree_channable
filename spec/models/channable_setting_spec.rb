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

  describe 'channable configuration' do
    before do
      create(:channable_setting, :active)
    end

    subject {SpreeChannable.configuration}

    it 'has a host' do
      expect(subject.host).to eq('http://example.com')
    end
    it 'has a url_prefix' do
      expect(subject.url_prefix).to eq('/products')
    end
    it 'has a image_host' do
      expect(subject.image_host).to eq('http://example.com')
    end
    it 'has a product_condition' do
      expect(ChannableSetting::PRODUCT_CONDITIONS).to include(subject.product_condition)
    end
    it 'has a brand' do
      expect(subject.brand).to eq('My Brand')
    end
    it 'has a delivery_period' do
      expect(subject.delivery_period).to eq('1 Day')
    end
    it 'sets user_variant_images' do
      expect(subject.use_variant_images).to be_falsey
    end
    it 'has a channable_api_key' do
      expect(subject.channable_api_key).to eq('jhg45jhk3g5j34khg5j-dsf78sdf')
    end
    it 'has a company_id' do
      expect(subject.company_id).to eq('company_123')
    end
    it 'has a project_id' do
      expect(subject.project_id).to eq('project_456')
    end
    it 'has a polling_interval' do
      expect(subject.polling_interval).to eq(20)
    end
    it 'has a active status' do
      expect(subject.active?).to be_truthy
    end
  end

end
