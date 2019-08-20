require 'byebug'

RSpec.describe Spree::Product, type: :model do
  before do
    5.times do |i|
      create_list(:variant, 10, product: create(:base_product, sku: "P_SKU_#{i}"))
    end
    create(:channable_setting)
  end

  describe 'variant feed' do
    let(:products) {Spree::Product.all}
    let(:feed) {Spree::Product.to_channable_variant_xml(products)}

    it 'has multiple products' do
      expect(products.count).to be > 1
    end

    it 'creates a variant feed' do
      expect(feed).to be_kind_of(String)
    end

    it 'has products' do
      result = Nokogiri::XML.parse(feed)
      expect(result.search('variants/variant').size).to eq 50
    end
  end

  describe 'product feed' do
    let(:products) {Spree::Product.all}
    let(:feed) {Spree::Product.to_channable_product_xml(products)}

    it 'has multiple products' do
      expect(products.count).to be > 1
    end

    it 'creates a variant feed' do
      expect(feed).to be_kind_of(String)
    end

    it 'has products' do
      result = Nokogiri::XML.parse(feed)
      expect(result.search('products/product').size).to eq 5
    end
  end
end
