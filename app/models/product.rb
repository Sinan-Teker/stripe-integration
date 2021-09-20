class Product < ApplicationRecord
    validates :name, presence: true 
    validates :price, presence: true 

    def to_s
        name
    end

    # update price
    def price_in_cents
        (price*100).to_i
    end

    # product,price create and send to data in Stripe 
    after_create do
        product = StripeServices.new(nil,name,nil,nil).create_product
        price = StripeServices.new(nil,product,self.price_in_cents,nil).create_price
        update(stripe_product_id: product.id)
        update(stripe_price_id: price.id)
    end

    # product price update this line.
    after_update :new_product_price, if: :saved_change_to_price?
    def new_product_price
        price = StripeServices.new(nil,self.stripe_product_id,self.price_in_cents,nil).price_update
        update(stripe_price_id: price.id)
    end

end