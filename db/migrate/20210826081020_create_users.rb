class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :ema
      t.string :email, null: false
      t.string :sifre_data

      t.timestamps
    end
  end
end
