class UsersController < ApplicationController
  def index
    #テスト用でHello Worldを返す
    render json: {message: 'Deploy_test Hello World!'}
  end
end
