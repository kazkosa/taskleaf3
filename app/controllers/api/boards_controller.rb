class Api::BoardsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    @boards = Board.joins(:users).where(project_id: params[:project_id]).where(users: {id: current_user.id} ).select("boards.*, board_members.role")
  end

  def create
    @board = Board.new(board_params_create)
    @board.board_members.each_with_index do |member, index|
      member.role = 0
    end

    if @board.save
      @board = Board.joins(:users).where(id: @board.id).where(users: {id: current_user.id} ).select("boards.*, board_members.role").first
      render :show, status: :created
    else
      render json: @board.errors, status: :unprocessable_entity
    end
  end

  def show
    @board = Board.joins(:users).select("boards.*, board_members.role").where({ id: params[:id] }).where(users: { id: current_user.id } ).first
    @board_check_join = !!@board || false
    @board = Board.find(params[:id]) unless @board
    
    project = @board.project

    if project.workspace_id
      @workspace = Workspace.joins(:users).select("workspaces.*, workspace_members.role").where(id: project.workspace_id, users: { id: current_user.id }).first
      if @workspace && @workspace.role_before_type_cast == 0
        @project = project
        render :show_ws_manager
      else
        @project = Project.joins(:users).select("projects.*, project_members.role").where(id: project.id, users: { id: current_user.id }).first
        if @project && @project.role_before_type_cast == 0
          render :show_pj_manager
        end
      end
    else
      @project = Project.joins(:users).select("projects.*, project_members.role").where(id: project.id, users: { id: current_user.id }).first
      if @project && @project.role_before_type_cast == 0
        render :show_pj_manager
      end
    end

  end

  def update
    @board = Board.find(params[:id])
    if @board.update_attributes(board_params)
      @board = Board.joins(:users).where(id: @board.id).where(users: {id: current_user.id} ).select("boards.*, board_members.role").first
      render :show, status: :created
    else
      render json: @board.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @board = Board.find(params[:id])
    if @board.destroy
      head :no_content
    else
      render json: @board.errors, status: :unprocessable_entity
    end
  end

  def update_members
    @board = Board.find(params[:id])
    if board_params_update[:user_ids] && \
      @board.check_member(board_params[:project_id], board_params_update[:user_ids], board_member_params[:roles]) && \
      @board.update(board_params_update) && \
      @board.update_members(board_params_update[:user_ids], board_member_params[:roles])

      @board = Board.joins(:users).where(id: @board.id).where(users: {id: current_user.id} ).select("boards.*, board_members.role").first
      @members = @board.build_member
      render :show, status: :created

    else
      render json: @board.errors, status: :unprocessable_entity
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def board_params_create
    params.fetch(:board, {}).permit(:name, :description, :project_id).merge(user_ids: [current_user.id])
  end

  def board_params
    params.fetch(:board, {}).permit(:name, :description, :project_id)
  end

  def board_params_update
    params.require(:board).permit(user_ids: [] )
  end

  def board_member_params
    params.require(:board_member).permit(roles: [], sendmail_user_ids: [])
  end
end