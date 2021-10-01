# Stripe Integration Application with Ruby on Rails 
# (_Ruby on Rails ile Stripe Entegrasyon Uygulaması_)
***
## Installation (_Kurulum_)
Firstly create a new project in Ruby on Rails
```sh
rails new project_name 
```
After add Stripe API key in Ruby on Rails application credentials.yml file
(_Öncelikle Ruby on Rails uygulamasının credentials.yml dosyasına Stripe API anahtarlarını ekleyin_)
```sh
#Use any code editor (nano or vim etc.)
EDITOR=nano rails credentials:edit
```
![](https://i.hizliresim.com/dww41te.jpg)

After create _../config/initializers/stripe.rb_ file :
```sh
require 'stripe'
Stripe.api_key = Rails.application.credentials[:stripe][:secret_key]
```
Authentication processing is finish, now create a homepage but for this we need to update the _../config/routes.rb_ and create _../app/controllers/home_controller.rb_ and _../app/views/home/index.html.erb_ file: 
***
#### _../config/routes.rb_
```sh
Rails.application.routes.draw do

  root to: "home#index"
  
end
```
***
#### _../app/controllers/home_controller.rb_
```sh
class HomeController < ApplicationController

    def index
    end
    
end
```
***
#### _../app/views/home/index.html.erb_

```sh
<p>Hello World</p>
```
***
Finally create the database 
```sh
rails db:create
```
***
## Create the Migration, Models, Controllers, Views and Services

I use three models 
* current.rb
* user.rb
* product.rb

#### Create _..app/models/current.rb_
```sh
class Current < ActiveSupport::CurrentAttributes
    attribute :user
end
```
#### Create _..app/models/user.rb_
```sh
rails g model User email:string password_digest:string
rails g migration add_stripe_customer_id_to_user stripe_customer_id:string
and migration db
rails db:migrate
```
```sh
class User < ApplicationRecord
    has_secure_password
    
    validates :email, presence: true, format: { with: /\A[^@\s]+@[^@\s]+\z/, message:'Email adresi geçersiz,lütfen kontrol ediniz' }

    def to_s
        email
    end

    after_create do
        customer = StripeServices.new(email,nil,nil,nil).create_customer
        update(stripe_customer_id: customer.id)
    end
end
```

#### And create _../app/models/product.rb_
```sh
rails g scaffold product name:string price:decimal
rails g migration add_stripe_price_id_to_product stripe_product_id:string
rails g migration add_stripe_price_id_to_product stripe_price_id:string
and migration db
rails db:migrate
```
```sh
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
        tax_rate = StripeServices.new(nil,nil,nil,nil).taxrate_create
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
```
***

Create a user registration and destroy pages and controllers 

#### Create _../app/controllers/kayit_controller.rb_ file:
```sh
class KayitController < ApplicationController
    
    def new
        @user = User.new
    end

    def create
        @user = User.new(user_params)
        if @user.save
            session[:user_id] = @user.id
            session[:cart] = []
            redirect_to root_path, notice: "Başarılı bir şekilde kullanıcı oluşturuldu."
        else
            flash[:alert] = "Kullanıcı oluşturulurken bir problemle karşılaşıldı. Tekrar deneyin..!"
            render :new
        end
    end

    def destroy
        # Stripe customer delete in current session
        @user = User.find_by(id: session[:user_id])
        StripeServices.new(@user.stripe_customer_id,nil,nil,nil).delete_customer
        @user.destroy
        redirect_to root_path, notice: "Hesabınız başarılı bir şekilde silinmiştir." 
    end

    private

    def user_params
        params.require(:user).permit(:email, :password, :password_confirmation)
    end
end
```
#### Create _../app/views/kayit/new.html.erb_
```sh
<div class = "d-flex align-items-center justify-content-center">
    <h1>Üye Kaydı</h1>
</div>
<%= form_with model: @user, url: kayit_path do |form| %>
  <% if @user.errors.any? %>
    <div class = "alert alert-danger">
        <% @user.errors.full_messages.each do |message| %>
            <div><%= message %></div>
        <% end %>
    </div>
  <%end%>
    <div class = "mb-3">
        <%= form.label :email %>
        <%= form.text_field :email, class: "form-control", placeholder: "example@example.com" %>
    </div>
    <div class = "mb-3">
        <%= form.label :Sifre %>
        <%= form.password_field :password, class: "form-control", placeholder: "Şifre" %>
    </div>
    <div class = "mb-3">
        <%= form.label :Sifre_Tekrarı %>
        <%= form.password_field :password_confirmation, class: "form-control", placeholder: "Şifre Tekrarı" %>
    </div>
    <div class = "mb-3">
        <%= form.submit "Kayıt Ol", class: "btn btn-primary" %>
    </div>    
<% end %>
```
#### Create _../app/views/kayit/destroy.html.erb_
```sh
<p>Hesabınız başarılı bir şekilde silinmiştir.</p>
```
***
Now create user login, log out session pages and controllers

#### Create _../app/controllers/sessions_controller.rb_ file:
```sh
class SessionsController < ApplicationController
    
    def destroy
        session[:user_id] = nil
        redirect_to root_path, notice: "Başarılı bir şekilde çıkış yaptınız."
    end

    def create
        user = User.find_by(email: params[:email])
        if user.present? && user.authenticate(params[:password])
            session[:user_id] = user.id
            session[:cart] = []
            redirect_to root_path, notice: "Başarılı bir şekilde giriş yaptınız."
        else
            flash[:alert] = "Yanlış email veya şifre"
            render :new
        end
    end
    
    def new

    end

end
```
#### Create _../app/views/sessions/new.html.erb_
```sh
<div class = "d-flex align-items-center justify-content-center">
    <h1>Giriş</h1>
</div>

<%= form_with url: giris_path do |form| %>
    <div class = "mb-3">
        <%= form.label :email %>
        <%= form.text_field :email, class: "form-control", placeholder: "example@example.com" %>
    </div>
    <div class = "mb-3">
        <%= form.label :Sifre %>
        <%= form.password_field :password, class: "form-control", placeholder: "Şifre" %>
    </div>
    <div class = "mb-3">
        <%= form.submit "Giriş Yap", class: "btn btn-primary"%>
    </div>
<% end %>
```
***
We are updating our products pages and controllers that we created with Scaffold

#### Update _../app/views/products/_form.html.erb_ file:
```sh
<%= form_with(model: product) do |form| %>
  <% if product.errors.any? %>
    <div id="error_explanation">
      <h2><%= pluralize(product.errors.count, "error") %> prohibited this product from being saved:</h2>

      <ul>
        <% product.errors.each do |error| %>
          <li><%= error.full_message %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <div class="card" style="width: 18rem;">
    <div class="card-body">
      <div class="field">
        <%= form.label :name, class: "form-label" %>
        <%= form.text_field :name, class: "form-control" %>
      </div>

      <div class="field mt-3">
        <%= form.label :price, class: "form-label" %>
        <%= form.text_field :price, class: "form-control" %>
      </div>

      <div class="mt-3">
        <%= form.submit class: "btn btn-primary" %>
      </div>
    </div>
  </div>
<% end %>
```
#### Update _../app/views/products/edit.html.erb_ file:
```sh
<h1>Editing Product</h1>

<%= render 'form', product: @product %>

<div class="mt-3">
    <%= link_to 'Show', @product, class:"btn btn-success" %> 
    <%= link_to 'Back', products_path, class:"btn btn-warning" %>
</div>
```
#### Update _../app/views/products/new.html.erb_ file:
```sh
<h1>New Product</h1>

<%= render 'form', product: @product %>

<div class="mt-3">
    <%= link_to 'Back', products_path, class:"btn btn-warning" %>
</div>
```
#### Update _../app/views/products/show.html.erb_
```sh
<div class="card" style="width: 18rem;">
  <div class="card-body">
    <p class="card-text">
      <strong>Name:</strong>
      <%= @product.name %>
    </p>

    <p class="card-text">
      <strong>Price:</strong>
      <%= @product.price %>
    </p>
    <%= link_to 'Edit', edit_product_path(@product), class:"btn btn-success" %> 
    <%= link_to 'Back', products_path, class:"btn btn-warning" %>
  </div>
</div>
```
#### And finally update _../app/views/products/index.html.erb_ file:
```sh
<div class="row">
  <div class="col-md-8">
    <div class="card">
      <div class="card-header d-flex justify-content-between">
        <div class="mt-2">
          <h3>Ürünler</h3>
        </div>
        <div class="mt-2">
          <%= link_to 'Yeni Ürün', new_product_path, class: "btn btn-primary" %>
        </div>
      </div>
      <div class="card-body">
        <table class="table">
          <thead>
              <th>İsim</th>
              <th>Fiyat</th>
              <th colspan="2"></th>
          </thead>
          <tbody>
            <% @products.each do |product| %>
              <tr>
                <td><%= product.name %></td>
                <td><%= product.price %><span> TRY</span></td>
                <td>
                  <% if @cart.include?(product) %>
                    <%= button_to "Sepetten Kaldır", remove_from_cart_path(product), method: :delete, class: "btn btn-warning btn-sm float-end" %>
                  <% else %>
                    <%= button_to "Sepete Ekle", add_to_cart_path(product), class: "btn btn-warning btn-sm float-end" %>
                  <% end %>
                </td>
                <td>
                  <%= link_to 'Göster', product, class: "btn btn-success btn-sm me-2" %>
                  <%= link_to 'Düzenle', edit_product_path(product), class: "btn btn-secondary btn-sm me-2" %>
                  <%= link_to 'Sil', product, method: :delete, data: { confirm: 'Ürünü silmek istediğinizden emin misiniz?' }, class: "btn btn-danger btn-sm" %>
                </td>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>
    </div>
  </div>
  <div class="col-md-4">
    <div class="card mb-2">
      <div class="card-header d-flex justify-content-between">
        <div class="mt-2">
          <h6>Alınan Ürün Sepeti</h6>
        </div>
        <% if @cart.present? %>
          <%= button_to "Satın Al", buy_path, remote: request.xhr?, data: { disable_with: "Bekleyin..." }, class: "btn btn-primary" %>
        <% end %>
      </div>
      <div class="card-body">
        <% @cart.each do |product| %>
        <blockquote class="border-bottom mb-0">
            <p><%= product.name %></p>
            <footer class="blockquote-footer mb-1"><%= product.price%> <cite title="Source Title">TRY</cite></footer>
          </blockquote>
        <% end %>
      </div>
    </div>
  </div>
</div>
```
***
We set a payment method to receive payment. Now create a payment method pages and controllers files.

#### Create _../app/controllers/payment_controller_ file:
```sh
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
```
#### Create _../app/views/payment/index.html.erb_ file:
```sh
<div class="card text-center">
  <div class="card-body">
    <h5 class="card-title">Hoşgeldin <%= @user %></h5>
    <p class="card-text">Yeni bir ödeme yöntemi girmek ister misin?</p>
      <a>
        <%= form_tag create_payment_method_path, id: "create-payment-method" do  %>
            <%= link_to "Ödeme Yöntemi Gir", add_payment_method_path, remote: true, class: "btn btn-primary" %>
        <% end %>
      </a>
  </div>
</div>
```
#### Create _../app/views/payment/new_card.js.erb_ file:
```sh
var handler = StripeCheckout.configure({
    key: '<%= Rails.application.credentials[:stripe][:public_key] %>',
    //get a publishable key that we put in editor
    locale: 'auto',
    //handle translation
    name: "Yeni Ödeme Yöntemi",
    description: "Kredi kartı bilgilerinizi giriniz.",
    email: "<%= Current.user.email %>",
    panelLabel: "Ödeme Yöntemi Ekle",
    allowRememberMe: false,
    token: function (token) {
        var form = document.getElementById('create-payment-method');
        //we will create element with this id in the next step
        var hiddenInput = document.createElement('input');
        hiddenInput.setAttribute('type', 'hidden');
        hiddenInput.setAttribute('name', 'stripeToken');
        hiddenInput.setAttribute('value', token.id);
        //creating an <input type="hidden" name="stripeToken" value="<id>"/>. We will need this information in the next steps to link a user to his card 
        form.appendChild(hiddenInput);
        //adding this input when we use a form.
        form.submit();
    }
});

handler.open();

window.addEventListener('popstate', function() {
    handler.close();
});
```
***
We can now buy the products we put in the cart. We create a buy page and controllers for this.

#### Create _../app/controllers/buy_controller_ file:
```sh
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
```
#### Create _../app/views/buy/create.html.erb_ file:
```sh
<div class="card mb-2">
  <div class="card-header d-flex justify-content-between">
    <h3>Alınan Ürün Sepeti</h3>
    <%= form_tag buy_path, method: 'get', id: "buy-form" do %>
      <span class= "payment-errors"></span>
      <script src="https://checkout.stripe.com/checkout.js" class="stripe-button"
        data-key="<%= Rails.application.credentials[:stripe][:public_key] %>"
        data-description="Ödeme"
        data-email=<%= Current.user.email %>
        data-amount= <%= (@amount*100).to_i %>
        data-currency="TRY"
        data-panel-label="Ödeme Yap"
        data-locale="auto">
      </script>
    <% end %>
  </div>
  <div class="card-body">
    <% @cart.each do |product| %>
     <blockquote class="border-bottom mb-0">
        <p><%= product.name %></p>
        <footer class="blockquote-footer mb-1"><%= product.price%> <cite title="Source Title">TRY</cite></footer>
      </blockquote>
    <% end %>
  </div>
</div>
```
#### Create _../app/views/buy/new.html.erb_ file:
```sh
<h2>Ödemeniz Başarıyla Gerçekleştirildi.</h2>
```
***
We can choose any of the monthly or yearly subscription options with the payment method you defined earlier.
We create a membership pages and controllers for this.
#### Create _../app/controllers/subscription_controller_ file:
```sh
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

      # create subscription schedule 1 hour current customer
      # subscription_schedule = StripeServices.new(customer,subscription.start_date,plan_id,nil).subscription_schedule
      
      # customer subscription plan create 
      subscription = StripeServices.new(customer,plan_id,nil,nil).subscription_create

      subscription.save
      
      redirect_to products_path
    end

    def destroy
      @user = Current.user.email
    end

    def refund
      customer = Stripe::Customer.new Current.user.stripe_customer_id
      # we define our customer

      subscription = StripeServices.new(customer.id,nil,nil,nil).subscription_list

      # current subscription retireve call
      retrieve_subscription = StripeServices.new(subscription["data"][0]["id"],nil,nil,nil).subscription_retrieve

      # invoice list call
      invoice_list = StripeServices.new(Current.user.stripe_customer_id,nil,nil,nil).invoice_list

      # current customer invoice retrieve
      invoice_retrieve = StripeServices.new(invoice_list["data"][0]["id"],nil,nil,nil).invoice_retrieve

      # current subscription payment refund
      subscription_refund = StripeServices.new(nil,invoice_list["data"][0]["charge"],invoice_retrieve.lines["data"][0]["amount"],nil).subscription_refund

      # current customer subscription cancel
      subscription_cancel = StripeServices.new(subscription["data"][0]["id"],nil,nil,nil).cancel_subscription

      redirect_to products_path
    end
end
```
#### Create _../app/views/subscription/new.html.erb_ file:
```sh
<div class="card text-center">
  <div class="card-header">
    <h2>Yeni bir kart tanımlama işlemi başarılı bir şekilde gerçekleştirildi.</h2>
  </div>
  <div class="card-body">
    <h4 class="card-title">Select your Monthly or Yearly Subscription</h4>
    <%=form_tag subscribe_path, method: :post do %>
    <div class="row">
      <div class="col-md-4"></div>
      <div class="col-md-4 text-center">
        <div class="form-group">
          <select class="form-select" name="plan_id">
            <option selected>Üyelik(Yıllık/Aylık) Seçin</option>
              <% @plan.each do |plans| %>
                <option value="<%= plans.id %>"><%= plans.amount/100 %>/TRY <%= plans.nickname %></option>
              <%end%>
          </select>
        </div>
      </div>
      <div class="col-md-4"></div>
    </div>
    <div class="row">
      <div class="col-md-12 mt-2 text-center">
        <%= submit_tag 'Submit My Choice', class: "btn btn-primary" %>
      </div>
    </div>
    <% end %>
  </div>
</div>
```
#### Create _../app/views/subscription/destroy.html.erb_ file:
```sh
<div class="card text-center">
  <div class="card-body">
    <h5 class="card-title">Hoşgeldin <%= @user %></h5>
    <p class="card-text">Üyeliğinizi iptal etmek istediğinize emin misiniz?</p>
      <a>
        <%=form_tag refund_path, method: :post do %>
          <%= submit_tag "Üyeliği İptal Et", class: "btn btn-primary" %>
        <% end %>
      </a>
  </div>
</div
```
***
After all this, we define our Stripe service.

#### Create _../app/services/stripe_services.rb_ file:
```sh
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
        Stripe::Product.create(
            name: @product,
        )
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
        Stripe::Customer.retrieve(
            @user,
        )
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
        Stripe::Charge.capture(
            @product,
        )
    end

    # Current user/customer delete stripe data
    def delete_customer
        Stripe::Customer.delete(
            @user,
        )
    end

    # Current product call
    def retrieve_product
        Stripe::Product.retrieve(
            @product,
        )
    end

    # price update line.
    def price_update
        Stripe::Price.create(
            product: @product,
            unit_amount: @money,
            currency: 'TRY'
        )
    end

    # listed customer subscription
    def subscription_list
        Stripe::Subscription.list(
            customer: @user,
            limit: 1,
        )
    end

    # create customer subscription
    def subscription_create
        Stripe::Subscription.create({
            customer: @user,
            items: [{plan: @product}],
        })
    end

    # current customer subscription call
    def subscription_retrieve
        Stripe::Subscription.retrieve(
            @user,
        )
    end

    # payment taxrate create
    def taxrate_create
        Stripe::TaxRate.create({
            display_name: 'MB',
            description: 'Merkez Bankasi Turkey',
            jurisdiction: 'TR',
            percentage: 18,
            inclusive: true,
        })
    end

    # customer subscription schedule
    def subscription_schedule
        Stripe::SubscriptionSchedule.create({
            customer: @user,
            start_date: @product,
            end_behavior: 'release',
            phases: [
                {
                items: [
                    {
                    price: @money,
                    quantity: 1,
                    },
                ],
                iterations: 12,
                },
            ],
        })
    end

    # cancel customer subscription
    def cancel_subscription
        Stripe::Subscription.delete(
            @user,
        )
    end

    # current customer subscription invoice retrieve
    def invoice_retrieve
        Stripe::Invoice.retrieve(
            @user,
        )
    end

    # Current invoice list call
    def invoice_list
        Stripe::Invoice.list({
            customer: @user,
            limit: 1,
        })
    end

    # Current customer subscription cancel and refund money
    def subscription_refund
        Stripe::Refund.create({
            charge: @product,
            amount: @money,
        })
    end

    # create invoice_item for customer
    def invoice_item_create
        Stripe::InvoiceItem.create({
          customer: @user,
          price: @money,
        })
    end

    # create invoice for customer.
    def create_invoice
        Stripe::Invoice.create({
          customer: @user,
        })
    end

    # new source create
    def create_source
        Stripe::Customer.create_source(
          @user,
          {source:'tok_visa'},
        )
    end

    # customer source delete
    def delete_source
        Stripe::Customer.delete_source(
          @user,
          @product,
        )
    end

    # product delete line.
    def product_delete
        Stripe::Product.delete(
           @product
        )
    end

end
```
***
We add a navigation bar to our homepage
#### Create the _../app/views/shared/_ _navbar.html.erb_ file:
```sh
<nav class="navbar navbar-expand-lg navbar-light bg-light">
    <div class="container-fluid">
      <%= link_to "Logo", root_path, class: "navbar-brand" %>
      <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
        <span class="navbar-toggler-icon"></span>
      </button>
      <div class="collapse navbar-collapse" id="navbarNav">
        <ul class="navbar-nav">
          <li class="nav-item">
            <%= link_to "Ana Sayfa", root_path, class: "nav-link active"%>
          </li>
          <li class="nav-item">
            <%= link_to "Ürünler", products_path, class: "nav-link active"%>
          </li>
        </ul>
        <ul class="navbar-nav ms-auto mb-2 mb-lg-0">
        <% if Current.user %>
          <li class="nav-item dropdown">
          <a class="nav-link dropdown-toggle" href="#" id="navbarDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false"></a>
          <ul class="dropdown-menu" aria-labelledby="navbarDropdown">
            <li class="dropdown-item"> 
              <%= link_to "Çıkış Yap", cikis_path, method: :delete, class: "nav-link active" %> 
            </li>
            <li><hr class="dropdown-divider"></li>
            <li class="dropdown-item"> 
              <%= link_to "Üyeliği Yükselt", subscription_path, method: :get, class: "nav-link active" %> 
            </li>
            <li><hr class="dropdown-divider"></li>
            <li class="dropdown-item"> 
              <%= link_to "Üyeliği İptal Et", subscription_refund_path, method: :get, class: "nav-link active" %> 
            </li>
            <li><hr class="dropdown-divider"></li>
            <li class="dropdown-item">
              <%= link_to "Ödeme Yöntemi", payment_path, class: "nav-link active"%>
            </li>
            <li><hr class="dropdown-divider"></li>
            <li class="dropdown-item"> 
              <%= link_to "Kullanıcıyı Sil", erase_path, method: :delete, class: "nav-link active" %>
            </li>
          </ul>
        </li>
          <li class="nav-item">
            <a class="nav-link disabled"><%= Current.user.email %></a>
          </li>
        <% else %>
        <li class="nav-item">
          <%= link_to "Kayıt Ol", kayit_path, class: "nav-link" %>
        </li>
        <li class="nav-item">
          <%= link_to "Giriş Yap", giris_path, class: "nav-link" %>
        </li>
        <% end %>
      </div>
    </div>
</nav>
```
***
Finally, update our Routes.rb and layouts/application.html.erb folders.
#### Update the _../config/routes.rb_ file:
```sh
Rails.application.routes.draw do

  resources :products
  
  get "kayit", to: "kayit#new"
  post "kayit", to: "kayit#create"
  delete "erase", to: "kayit#destroy"

  get "giris", to: "sessions#new"
  post "giris", to: "sessions#create"

  delete "cikis", to: "sessions#destroy"

  post "products/add_to_cart/:id", to: "products#add_to_cart", as: "add_to_cart"
  delete "products/remove_from_cart/:id", to: "products#remove_from_cart", as: "remove_from_cart"

  get "buy", to: "buy#new"
  post "buy", to: "buy#create"

  get "/payment", to: "payment#index", as: :payment
  get "/card/new", to: "payment#new_card", as: :add_payment_method
  post "/card", to: "payment#create_card", as: :create_payment_method

  get "subscription", to: "subscription#new"
  post "/subscriptions", to: "subscription#subscribe", as: :subscribe
  get "/subscription/refund", to: "subscription#destroy"
  post "/refunds", to: "subscription#refund", as: :refund

  root to: "home#index"
end
```
#### Update the _../app/views/layouts/application.html.erb_ file:
```sh
<!DOCTYPE html>
<html>
  <head>
    <title>Stripe</title>
    <link rel = "icon" href = "https://cdn.iconscout.com/icon/free/png-64/stripe-3521744-2945188.png" type = "image/x-icon">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>

    
    <%= javascript_include_tag 'https://checkout.stripe.com/checkout.js' %>
    <script src="https://js.stripe.com/v3/"></script>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.0/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-KyZXEAg3QhqLMpG8r+8fhAXLRk2vvoC2f3B09zVXn8CA5QIVfZOJ3BCsw2P0p/We" crossorigin="anonymous">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.0/dist/js/bootstrap.bundle.min.js" integrity="sha384-U1DAWAznBHeqEIlVSCgzq+c9gqGAJn5c/t99JyeKa9xxaYpSvHU5awsuZVVFIhvj" crossorigin="anonymous"></script>
    <%= stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>
    <%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload' %>
  </head>

  <body>
    <%= render partial: "shared/navbar" %>
    <%= render partial: "shared/flash" %>
    <div class = "container pt-4">
      <%= yield %>
    </div>
  </body>
</html>
```