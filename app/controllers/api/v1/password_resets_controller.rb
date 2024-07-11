require Rails.root.join('app/controllers/application_controller.rb').to_s

module Api
  module V1
    class PasswordResetsController < ApplicationController
      def create
        user = User.find_by(email: params[:email])
        if user
          user.generate_reset_password_token!
          UserMailer.reset_password_email(user).deliver_now
          render json: { message: 'パスワードリセットメールを送信しました' }, status: :ok
        else
          render json: { error: 'メールアドレスが見つかりません' }, status: :not_found
        end
      end

      def edit
        @user = User.find_by(reset_password_token: params[:token])
        if @user && @user.password_token_valid?
          render :edit
        else
          redirect_to new_password_reset_path, alert: 'パスワードリセットの有効期限が切れました。'
        end
      end

      def update
        @user = User.find_by(reset_password_token: params[:token])
        if @user && @user.password_token_valid? && @user.update(password_params)
          @user.clear_reset_password_token!
          redirect_to login_path, notice: 'パスワードをリセットしました。ログインしてください。'
        else
          render :edit
        end
      end

      private

      def password_params
        params.require(:user).permit(:password, :password_confirmation)
      end
    end
  end
end
