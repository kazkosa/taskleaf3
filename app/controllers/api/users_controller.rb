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
    if params[:type] == 'project' && params[:workspace_id] && params[:workspace_id].to_i > 0
      @count = User.joins(:workspace_members).where("name LIKE :keyword OR email LIKE :keyword", keyword: "%#{params[:keyword]}%").where('workspace_members.workspace_id': params[:workspace_id]).where.not(id: exist_user_ids_params).count
    elsif params[:type] == 'board' && params[:project_id] && params[:project_id].to_i
      @count = User.joins(:project_members).where("name LIKE :keyword OR email LIKE :keyword", keyword: "%#{params[:keyword]}%").where('project_members.project_id': params[:project_id]).where.not(id: exist_user_ids_params).count
    else
      @count = User.where("name LIKE :keyword OR email LIKE :keyword", keyword: "%#{params[:keyword]}%").where.not(id: exist_user_ids_params).count
    end
    render :count, status: :ok
  end

  def index
    if params[:type] == 'project' && params[:workspace_id] && params[:workspace_id].to_i > 0
      @users = User.joins(:workspace_members).where("name LIKE :keyword OR email LIKE :keyword", keyword: "%#{params[:keyword]}%").where('workspace_members.workspace_id': params[:workspace_id]).where.not(id: exist_user_ids_params)
    elsif params[:type] == 'board' && params[:project_id] && params[:project_id].to_i
      @users = User.joins(:project_members).where("name LIKE :keyword OR email LIKE :keyword", keyword: "%#{params[:keyword]}%").where('project_members.project_id': params[:project_id]).where.not(id: exist_user_ids_params)
    else
      @users = User.where("name LIKE :keyword OR email LIKE :keyword", keyword: "%#{params[:keyword]}%").where.not(id: exist_user_ids_params)
    end
    render :index, status: :ok
  end

  private

  def exist_user_ids_params
    params[:exist_user_ids] ? params[:exist_user_ids].map{|n| n.to_i}: []
  end

end