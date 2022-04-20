class Api::WorkspacesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    @workspaces = Workspace.joins(:users).where(users: {id: current_user.id} ).select("workspaces.*, workspace_members.role")
    @projects = []
  end

  def create
    @workspace = Workspace.new(workspace_params_create)
    @workspace.workspace_members.each_with_index do |member, index|
      member.role = 0
    end
    if @workspace.save
      @workspace = Workspace.joins(:users).where({id: @workspace.id}).where(users: {id: current_user.id}).select("workspaces.*, workspace_members.role").first
      render :show, status: :created
    else
      render json: @workspace.errors, status: :unprocessable_entity
    end
  end

  def show
    @workspace = Workspace.joins(:users).select("workspaces.*, workspace_members.role").where({ id: params[:id] }).where(users: { id: current_user.id } ).first
  end

  def update
    @workspace = Workspace.joins(:users).select("workspaces.*, workspace_members.role").where({ id: params[:id] }).where(users: { id: current_user.id } ).first
    @projects = @workspace.projects.joins(:users).where(users: {id: current_user.id} ).select("projects.*, project_members.role")
    if @workspace.update_attributes(workspace_params)
      render :show, status: :created
    else
      render json: @workspace.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @workspace = Workspace.find(params[:id])
    if @workspace.destroy
      head :no_content
    else
      render json: @workspace.errors, status: :unprocessable_entity
    end
  end

  def update_members
    @workspace = Workspace.joins(:users).select("workspaces.*, workspace_members.role").where({ id: params[:id] }).where(users: { id: current_user.id } ).first
    @projects = @workspace.projects.joins(:users).where(users: {id: current_user.id} ).select("projects.*, project_members.role")

    if workspace_params_update[:user_ids] && @workspace.check_member(workspace_params_update[:user_ids], workspace_member_params[:roles])  && @workspace.update(workspace_params_update) && @workspace.update_members(workspace_params_update[:user_ids], workspace_member_params[:roles], workspace_member_params[:sendmail_user_ids], current_user)
      @members = @workspace.build_member
      render :show, status: :created
    else
      render json: @workspace.errors, status: :unprocessable_entity
    end
  end

  def search_child_members
    projects = Project.joins(:users).where(users: {id: params[:user_id]} ).where({workspace_id: params[:id]} ).select("projects.*, project_members.role")
    @projects = []
    @boards = []
    projects.each do |project|
      if project.role_before_type_cast == 0
        @projects << project
      end
      boards = project.boards.joins(:users).where(users: {id: params[:user_id]} ).select("boards.*, board_members.role")
      boards.each do |board|
        if board.role_before_type_cast == 0
          @boards << board
        end
      end
    end
    render :search_child_members
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def workspace_params_create
    params.fetch(:workspace, {}).permit(:name).merge(user_ids: [current_user.id])
  end

  def workspace_params
    params.fetch(:workspace, {}).permit(:name)
  end

  def workspace_params_update
    params.require(:workspace).permit(user_ids: [] )
  end

  def workspace_member_params
    params.require(:workspace_member).permit(roles: [], sendmail_user_ids: [])
  end
end