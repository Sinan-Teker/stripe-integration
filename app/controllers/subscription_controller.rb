class SubscriptionController < ApplicationController
    def new
        @plan = Stripe::Plan.list({limit: 2})
    end

    def subscribe
      if Current.user.stripe_customer_id.nil?
        redirect_to subscription_path, :flash => {:error => 'Öncelikle bir kart tanımlayın.!'}
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

      # invoice_item = StripeServices.new(customer,nil,plan_id,nil).invoice_item_create

      # invoice = StripeServices.new(customer,nil,nil,nil).create_invoice
      
      # customer subscription plan create 
      subscription = StripeServices.new(customer,plan_id,nil,nil).subscription_create

      subscription.save

      # invoice list call
      invoice_list = StripeServices.new(Current.user.stripe_customer_id,nil,nil,nil).invoice_list

      # current customer invoice retrieve
      invoice_retrieve = StripeServices.new(invoice_list["data"][0]["id"],nil,nil,nil).invoice_retrieve

      # current subscription payment refund
      subscription_refund = StripeServices.new(nil,invoice_list["data"][0]["charge"],invoice_retrieve.lines["data"][0]["amount"],nil).subscription_refund

      # create subscription schedule 1 hour current customer
      # subscription_schedule = StripeServices.new(customer,subscription.start_date,plan_id,nil).subscription_schedule

      # current customer subscription cancel
      subscription_cancel = StripeServices.new(subscription.id,nil,nil,nil).cancel_subscription
      
      redirect_to products_path
    end
end