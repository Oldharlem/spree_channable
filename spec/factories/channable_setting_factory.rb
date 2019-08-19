FactoryBot.define do
  factory :channable_setting do
    host "http://example.com"
    url_prefix "/products"
    image_host "http://example.com"
    product_condition ChannableSetting::PRODUCT_CONDITIONS.sample
    brand "My Brand"
    delivery_period "1 Day"
    use_variant_images false
    channable_api_key "jhg45jhk3g5j34khg5j-dsf78sdf"
    company_id "company_123"
    project_id "project_456"
    association :payment_method, factory: :check_payment_method
    polling_interval 20
    association :stock_location, factory: :stock_location
    active false

    trait :active do
      active true
    end
  end
end
