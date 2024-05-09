# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_account_update_params, only: [:update]

  # POST /resource
    def create
      super do |resource|
      if resource.persisted?
        render json: {message: 'アカウントを作成しました。'}, status: :created
      else
        render json: {error: @user.errors.full_messages}, status: :unprocessable_entity
      end
    end
  end

  # GET /resource/edit
  def edit
    super
  end

  # PUT /resource
  def update
    super
  end

  # DELETE /resource
  def destroy
    super
  end

  private

  def configure_account_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :email, :password])
  end
end
