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
        Stripe::Charge.create({
            customer: @user,
            amount: @money,
            description: 'Charge Complete',
            currency: 'TRY',
            capture: false,
        })
    end

    # charge capture line.
    def capture_charge
        Stripe::Charge.capture(@product)
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

    def subscription_list
        Stripe::Subscription.list(customer: @user)
    end

    def subscription_create
        Stripe::Subscription.create({
        customer: @user,
        items: [{plan: @product}], })
    end

    # create invoice_item for customer
    # def invoice_item_create
    #     Stripe::InvoiceItem.create({
    #     customer: @user,
    #     price: @money,
    #     })
    # end

    # create invoice for customer.
    # def create_invoice
    #     Stripe::Invoice.create({
    #     customer: @user,
    #     })
    # end

    # new source create
    # def create_source
    #     Stripe::Customer.create_source(
    #     @user,
    #     {source:'tok_visa'},
    #     )
    # end

    # customer source delete
    # def delete_source
    #     Stripe::Customer.delete_source(
    #     @user,
    #     @product,
    #     )
    # end

    # product delete line.
    # def product_delete
    #     Stripe::Product.delete(@product)
    # end

end