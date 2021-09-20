class KayitController < ApplicationController
    
    def new
        @user = User.new
    end

    def create
        @user = User.new(user_params)
        if @user.save
            session[:user_id] = @user.id
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