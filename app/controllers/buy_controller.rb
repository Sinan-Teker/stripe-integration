class BuyController < ApplicationController
    
    def new
        # Calculated amount_total line
        @amount = 0
        @cart.each do|c|
            @amount += c.price.to_i
        end
        
        # Find current user email data
        current_email = Current.user.email
        user =  User.where(email: current_email).first

        # Current customer call
        customer = StripeServices.new(user.stripe_customer_id,nil,nil,nil).retrieve_customer

        # Current user source call
        customer = StripeServices.new(user.stripe_customer_id,nil,nil,customer.default_source).retrieve_source

        # customer = StripeServices.new(user.stripe_customer_id,nil,nil,nil).create_source

        # charge create line
        charge = StripeServices.new(user.stripe_customer_id,nil,(@amount*100).to_i,nil).create_charge

        # charge capture line.
        charge_control = StripeServices.new(nil,charge.id,nil,nil).capture_charge

        # StripeServices.new(user.stripe_customer_id,customer.id,nil,nil,nil).delete_source

        # invoice for customer.
        # invoice = StripeServices.new(customer.id,nil,nil,nil).create_invoice


        # empty the cart after purchase
        session[:cart] = []


    end

    def create
        @amount = 0
        @cart.each do|c|
            @amount += c.price.to_i
        end
    end

end