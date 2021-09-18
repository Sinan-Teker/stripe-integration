class User < ApplicationRecord
    has_secure_password
    
    validates :email, presence: true, format: { with: /\A[^@\s]+@[^@\s]+\z/, message:'Email adresi geçersiz,lütfen kontrol ediniz' }

    def to_s
        email
    end

    after_create do
        customer = StripeServices.new(email,nil,nil).create_customer
        update(stripe_customer_id: customer.id)
    end
end