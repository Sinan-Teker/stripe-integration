class AddSifreDataKontrolToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :sifre_data_kontrol, :string
  end
end
