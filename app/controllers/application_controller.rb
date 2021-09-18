class ApplicationController < ActionController::Base
    before_action :set_current_user
    before_action :initialize_session
    before_action :load_cart

    private

    def initialize_session
        session[:cart] ||= [] # empty cart = empty array
    end

    def load_cart
        @cart = Product.find(session[:cart])
    end

    def set_current_user
        if session[:user_id]
            Current.user = User.find_by(id: session[:user_id])
        end
    end
end