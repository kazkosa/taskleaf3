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

  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def board_params
    params.fetch(:board, {}).permit(:name, :description, :project_id).merge(owner_id: current_user.id)
  end
end