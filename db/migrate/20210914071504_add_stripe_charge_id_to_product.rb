class AddStripeChargeIdToProduct < ActiveRecord::Migration[6.1]
  def change
    add_column :products, :stripe_charge_id, :string
  end
end
