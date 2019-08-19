RSpec.describe Spree::Product, type: :model do
  before do
    create_list(:variant, 10)
    create(:channable_setting)
  end

  describe 'variant feed' do
    let!(:products) {create_list(:product, 20)}
    let!(:feed) {Spree::Product.to_channable_variant_xml(products)}

    it 'has multiple products' do
      expect(products.count).to be > 0
    end


    it 'creates a variant feed' do
      expect(feed).to be_kind_of(String)
    end

    it 'has products' do
      expect(feed).to have_xml('/feed/variants')
    end
  end
end
