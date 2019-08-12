FactoryBot.define do
  factory :channable_setting do
    host { "http://example.com" }
    url_prefix { "/products" }
    image_host { "http://example.com" }
    product_condition { ChannableSetting::PRODUCT_CONDITIONS.sample }
    brand { "My Brand" }
    delivery_period { "1 Day" }
    use_variant_images { false }
    channable_api_key { "MyString" }
    company_id { "MyString" }
    project_id { "MyString" }
    association :payment_method, factory: :check_payment_method
    polling_interval { 1 }
    association :stock_location, factory: :stock_location
    active { false }

    trait :active do
      active { true }
    end
  end
end
