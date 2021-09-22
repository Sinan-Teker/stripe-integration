class BuyController < ApplicationController
    
    def new
        @amount = 0
        @cart.each do|c|
            @amount += c.price.to_i
        end
        
        current_email = Current.user.email
        user =  User.where(email: current_email).first

        customer = StripeServices.new(user.stripe_customer_id,nil,nil,nil).retrieve_customer

        customer = StripeServices.new(user.stripe_customer_id,nil,nil,customer.default_source).retrieve_source

        # customer = StripeServices.new(user.stripe_customer_id,nil,nil,nil).create_source

        charge = StripeServices.new(user.stripe_customer_id,nil,(@amount*100).to_i,nil).create_charge

        # StripeServices.new(user.stripe_customer_id,customer.id,nil,nil,nil).delete_source

        # invoice for customer.
        # invoice = StripeServices.new(customer.id,nil,nil,nil).create_invoice

        # charge capture line.
        # charge_control = StripeServices.new(nil,charge.id,nil,nil).capture_charge
    end

    def create
        @amount = 0
        @cart.each do|c|
            @amount += c.price.to_i
        end
    end

end