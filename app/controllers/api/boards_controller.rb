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
    @board = Board.find(params[:id])
    @project = @board.project
    if @project.workspace_id
      @workspace = Workspace.joins(:users).select("workspaces.*, workspace_members.*").where(id: @project.workspace_id, users: { id: current_user.id }).first
    end

  end

  def update
    @board = Board.find(params[:id])
    if @board.update_attributes(board_params)
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
    if board_params_update[:user_ids] && @board.check_member(board_params[:project_id], board_params_update[:user_ids], board_member_params[:roles]) && @board.update(board_params_update)
      success = true
      @board.board_members.each do |member|
        index = board_params_update[:user_ids].index(member.user_id)
        member.role = (board_member_params[:roles][index])

        unless member.save
          success = false
        end
      end
      if success
        @members = @board.build_member
        render :show, status: :created
      else
        render json: @board.errors, status: :unprocessable_entity
      end
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