class StripeServices

    def initialize(user,product,money,card)
        @user = user
        @product = product
        @money = money
        @card = card
    end

    # new customer create
    def create_customer
        Stripe::Customer.create(
            email: @user,
            description: 'Customer'
        )
    end

    # new product create
    def create_product
        Stripe::Product.create(name: @product)
    end

    # new product price amount create
    def create_price
        Stripe::Price.create(
            product: @product, 
            unit_amount: @money, 
            currency: "TRY"
        )
    end

    # Current customer call
    def retrieve_customer
        Stripe::Customer.retrieve(@user)
    end

    # Current customer card details call
    def retrieve_source
        Stripe::Customer.retrieve_source(
            @user,
            @card,
        )
    end

    # new charge create
    def create_charge
        Stripe::Charge.create(
            customer: @user,
            amount: @money,
            description: 'Charge Complete',
            currency: 'TRY'
        )
    end

    # Current user/customer delete stripe data
    def delete_customer
        Stripe::Customer.delete(@user)
    end

    # Current product call
    def retrieve_product
        Stripe::Product.retrieve(@product)
    end

    # price update line.
    def price_update
        Stripe::Price.create(
        product: @product,
        unit_amount: @money,
        currency: 'TRY'
        )
    end

    # new source create
    # def create_source
    #     Stripe::Customer.create_source(
    #     @user,
    #     {source:'tok_visa'},
    #     )
    # end

    # customer credit card delete
    # def delete_source
    #     Stripe::Customer.delete_source(
    #     @user,
    #     @product,
    #     )
    # end

    # new payment intent create line.
    # def create_payment_intents
    #     Stripe::PaymentIntent.create({
    #     amount: @money,
    #     currency: 'TRY',
    #     payment_method_types: ['card'],
    #     })
    # end
    
    # charge capture line.
    # def capture_charge
    #     Stripe::Charge.capture(@product)
    # end

    # create invoice for customer.
    # def create_invoice
    #     Stripe::Invoice.create({
    #     customer: @user,
    #     }, stripe_account: 'acct_1JNAwmFXEHfurYPJ')
    # end

    # product delete line.
    # def product_delete
    #     Stripe::Product.delete(@product)
    # end

end