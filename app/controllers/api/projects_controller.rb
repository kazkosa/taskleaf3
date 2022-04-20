class Api::ProjectsController < ApplicationController
  skip_before_action :verify_authenticity_token

  # GET /projects
  def index
    @pj_owner_flg = false
    if params[:workspace_id].to_i > 0
      @projects = Project.joins(:users).where({ workspace_id: params[:workspace_id].to_i }).where(users: {id: current_user.id} ).select("projects.*, project_members.role")
    else
      @projects = Project.joins(:users).where({ workspace_id: nil }).where(users: {id: current_user.id} ).select("projects.*, project_members.role")
    end
    @boards = []
    @projects.each do |project|
      if project.role == 0
        @pj_owner_flg = true
        @boards[project.id] = project.boards
      else
        @boards[project.id] = project.boards.joins(:users).where(users: {id: current_user.id} ).select("boards.*, board_members.role")
      end
    end
  end

  def index_manager
    @projects = Project.where(workspace_id: params[:workspace_id].to_i)
    @projects_check_join = []
    @projects.each do |project|
      member = ProjectMember.find_by(user_id: current_user.id, project_id: project.id) 
      @projects_check_join[project.id] = !member.nil?
    end
    #
  end

  # POST /project
  def create
    @project = Project.new(project_params_create)
    @project.project_members.each_with_index do |member, index|
      member.role = 0
    end
    if @project.save
      @project = Project.joins(:users).where({id: @project.id}).where(users: {id: current_user.id}).select("projects.*, project_members.role").first
      render :show, status: :created
    else
      render json: @project.errors, status: :unprocessable_entity
    end
  end

  def show
    @project = Project.joins(:users).select("projects.*, project_members.role").where(id: params[:id], users: { id: current_user.id }).first
    @projects_check_join = !!@project || false
    @project = Project.find(params[:id]) unless @project
    @pj_owner_flg = false
    if @project.workspace_id
      @workspace = Workspace.joins(:users).select("workspaces.*, workspace_members.role").where(id: @project.workspace_id, users: { id: current_user.id }).first
      if @workspace && @workspace.role_before_type_cast == 0
        render :show_manager
      else
        if @project && @project.role_before_type_cast == 0
          @boards = @project.boards
          @pj_owner_flg = true
        else
          @boards = @project.boards.joins(:users).where(users: {id: current_user.id} ).select("boards.*, board_members.role")
        end
      end
    else
      if @project && @project.role_before_type_cast == 0
        @boards = @project.boards
        @pj_owner_flg = true
      else
        @boards = @project.boards.joins(:users).where(users: {id: current_user.id} ).select("boards.*, board_members.role")
      end
    end
  end

  def update
    @project = Project.joins(:users).select("projects.*, project_members.role").find_by(id: params[:id])
    @boards = @project.boards.joins(:users).where(users: {id: current_user.id} ).select("boards.*, board_members.role")
    if @project.update_attributes(project_params)
      render :show, status: :created
    else
      render json: @project.errors, status: :unprocessable_entity
    end
  end

  def search_child_members
    boards = Board.joins(:users).where(users: {id: params[:user_id]} ).where({project_id: params[:id]} ).select("boards.*, board_members.role")
    @boards = []
    boards.each do |board|
      if board.role_before_type_cast == 0
        @boards << board
      end
    end
    render :search_child_members
  end

  def destroy
    @project = Project.find(params[:id])
    if @project.destroy
      head :no_content
    else
      render json: @project.errors, status: :unprocessable_entity
    end
  end

  def update_members
    @project = Project.joins(:users).select("projects.*, project_members.role").find_by(id: params[:id])
    @boards = @project.boards.joins(:users).where(users: {id: current_user.id} ).select("boards.*, board_members.role")
    if project_params_update[:user_ids] && \
      @project.check_member(project_params_update[:workspace_id], project_params_update[:user_ids], project_member_params[:roles])  && \
      @project.update(project_params_update) && \
      @project.update_members(project_params_update[:user_ids], project_member_params[:roles], project_member_params[:sendmail_user_ids], current_user)
      
      @members = @project.build_member
      render :show, status: :created
    else
      render json: @project.errors, status: :unprocessable_entity
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def project_params_create
    params.fetch(:project, {}).permit(:name, :description, :workspace_id).merge(user_ids: [current_user.id])
  end

  def project_params
    params.fetch(:project, {}).permit(:name, :description, :workspace_id)
  end

  def project_params_update
    params.require(:project).permit(:workspace_id, user_ids: [])
  end

  def project_member_params
    params.require(:project_member).permit(roles: [], sendmail_user_ids: [])
  end
end