class Api::UsersController < ApplicationController
  skip_before_action :verify_authenticity_token

  def show
    @user = User.find(params[:id])
    if @user
      render :show, status: :ok
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

end