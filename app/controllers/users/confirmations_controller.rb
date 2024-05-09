# frozen_string_literal: true

class Users::ConfirmationsController < Devise::ConfirmationsController

  # GET /resource/confirmation/new
  # def new
  #   super
  # end

  # POST /resource/confirmation
#   def create
#     @user = User.new(user_params)
#     if @user.save
#       render json: {message: 'アカウントを作成しました。'}, status: :created
#     else
#       render json: {error: @user.errors.full_messages}, status: :unprocessable_entity
#     end
#   end

  # GET /resource/confirmation?confirmation_token=abcdef
  # def show
  #   super
  # end

  # protected

  # The path used after resending confirmation instructions.
  # def after_resending_confirmation_instructions_path_for(resource_name)
  #   super(resource_name)
  # end

  # The path used after confirmation.
  # def after_confirmation_path_for(resource_name, resource)
  #   super(resource_name, resource)
  # end

  # private

  # def user_params
  #   params.require(:user).permit(:name, :email, :password)
  # end
end
