class AddPaymentMethodForChannable < ActiveRecord::Migration[5.0]
  def change

    Spree::PaymentMethod.find_or_create_by(name: 'Paid at channable', display_on: :back_end, type: 'Spree::PaymentMethod::Check', active: true)

  end
end
