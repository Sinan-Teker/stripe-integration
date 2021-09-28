class PaymentController < ApplicationController
    before_action :set_current_user
    
    def index
        @user = Current.user.email
    end

    def new_card
        respond_to do |format|
            format.js
        end
    end

    def create_card 
        respond_to do |format|
            if Current.user.stripe_customer_id.nil?
                customer = StripeServices.new(Current.user.email,nil,nil,nil).create_customer
                #Here we are creating a stripe customer with the help of the StripeServices and pass as parameter current user email. 
                Current.user.update(:stripe_customer_id => customer.id)
                #we are updating user and giving to it stripe_customer_id which is equal to id of customer on Stripe
            end

            card_token = params[:stripeToken]
            #it's the stripeToken that we added in the hidden input
            if card_token.nil?
                format.html { redirect_to payment_path, error: "Kredi kartı verisi bulunamadı. Tekrar deneyin."}
            end
            #checking if a card was giving.

            customer = Stripe::Customer.new Current.user.stripe_customer_id
            customer.source = card_token
            #we're attaching the card to the stripe customer
            customer.save

            format.html { redirect_to products_path }
        end
    end

end
