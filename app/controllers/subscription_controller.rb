class SubscriptionController < ApplicationController
    def new
        @plan = Stripe::Plan.list({limit: 2})
    end

    def subscribe

      if Current.user.stripe_customer_id.nil?
        redirect_to subscription_path, :flash => {:error => 'Firstly you need to enter your card'}
        return
      end
      #if there is no card

      customer = Stripe::Customer.new Current.user.stripe_customer_id
      #we define our customer

      subscriptions = StripeServices.new(customer.id,nil,nil,nil).subscription_list
      subscriptions.each do |subscription|
        subscription.delete
      end
      #we delete all subscription that the customer has. We do this because we don't want that our customer to have multiple subscriptions

      plan_id = params[:plan_id]
      subscription = StripeServices.new(customer,plan_id,nil,nil).subscription_create

      subscription.save
      redirect_to products_path
    end
end
