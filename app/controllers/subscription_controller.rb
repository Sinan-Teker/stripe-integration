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

      subscriptions = Stripe::Subscription.list(customer: customer.id)
      subscriptions.each do |subscription|
        subscription.delete
      end
      #we delete all subscription that the customer has. We do this because we don't want that our customer to have multiple subscriptions

      plan_id = params[:plan_id]
      subscription = Stripe::Subscription.create({
        customer: customer,
        items: [{plan: plan_id}], })

      subscription.save
      redirect_to subscription_path
    end
end
