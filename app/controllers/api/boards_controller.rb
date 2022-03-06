class Api::BoardsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
  end

  def create
    @board = Board.new(board_params)

    if @board.save
      render :show, status: :created
    else
      render json: @board.errors, status: :unprocessable_entity
    end
  end

  def show
    @board = Board.find(params[:id])
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
    if @board.update(board_params_update) && @board.ensure_no_member
      success = true
      if board_params_update[:user_ids]
        @board.board_members.each do |member|
          index = board_params_update[:user_ids].index(member.user_id)
          member.role = (board_member_params[:roles][index])

          unless member.save
            success = false
          end
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
  def board_params
    params.fetch(:board, {}).permit(:name, :description, :project_id).merge(user_ids: [current_user.id])
  end

  def board_params_update
    params.require(:board).permit(user_ids: [] )
  end

  def board_member_params
    params.require(:board_member).permit(roles: [], sendmail_user_ids: [])
  end
end