class BuyController < ApplicationController
    
    def new
        
    end

    def create
        @amount = 0
        @cart.each do|c|
            @amount += c.price.to_i
        end

        current_email = Current.user.email
        user =  User.where(email: current_email).first
        customer = StripeServices.new(user.stripe_customer_id,nil,nil).create_source

        customer = StripeServices.new(user.stripe_customer_id,nil,nil).retrieve_customer

        charge = StripeServices.new(customer.id,nil,(@amount*100).to_i).create_charge

        StripeServices.new(user.stripe_customer_id,customer.default_source,nil).delete_source

        # invoice for customer.
        # invoice = StripeServices.new(customer.id,nil,nil).create_invoice

        # charge capture line.
        # charge_control = StripeServices.new(nil,charge.id,nil).capture_charge
    end

end