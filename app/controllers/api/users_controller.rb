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

  def count
    @count = User.where("name LIKE :keyword OR email LIKE :keyword", keyword: "%#{params[:keyword]}%").where.not(id: exist_user_ids_params).count
    render :count, status: :ok
  end

  def index
    @users = User.where("name LIKE :keyword OR email LIKE :keyword", keyword: "%#{params[:keyword]}%").where.not(id: exist_user_ids_params)
    render :index, status: :ok
  end

  private

  def exist_user_ids_params
    params[:exist_user_ids] ? params[:exist_user_ids].map{|n| n.to_i}: []
  end

end