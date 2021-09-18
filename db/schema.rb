# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_09_17_113451) do

  create_table "credit_cards", force: :cascade do |t|
    t.string "digits"
    t.integer "mount"
    t.integer "year"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.decimal "price"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "stripe_product_id"
    t.string "stripe_price_id"
    t.string "stripe_charge_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "ema"
    t.string "email"
    t.string "sifre_data"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "sifre_data_kontrol"
    t.string "password_digest"
    t.string "password"
    t.string "stripe_customer_id"
    t.string "firstname"
    t.string "lastname"
  end

end
