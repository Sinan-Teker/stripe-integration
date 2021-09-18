class SessionsController < ApplicationController
    
    def destroy
        session[:user_id] = nil
        redirect_to root_path, notice: "Başarılı bir şekilde çıkış yaptınız."
    end

    def create
        user = User.find_by(email: params[:email])
        if user.present? && user.authenticate(params[:password])
            session[:user_id] = user.id
            redirect_to root_path, notice: "Başarılı bir şekilde giriş yaptınız."
        else
            flash[:alert] = "Yanlış email veya şifre"
            render :new
        end
    end
    
    def new

    end

end