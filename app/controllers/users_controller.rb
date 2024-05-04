class UsersController < ApplicationController
  def index
    #テスト用でHello Worldを返す
    render json: {message: 'Hello World!'}
  end
end
