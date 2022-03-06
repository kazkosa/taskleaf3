class Api::BoardMembersController < ApplicationController
  skip_before_action :verify_authenticity_token

  # GET /members
  def index
    @board = Board.find(params[:board_id])
    @members = @board.build_member
  end

  def update
    @board_member = BoardMember.find(params[:id])
    @board = @board_member.board
    @members = @board.build_member
    if @board_member.update_attributes(member_params)
      render :index, status: :created
    else
      render json: @board.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @board_member = BoardMember.find(params[:id])
    if @board_member.destroy
      head :no_content
    else
      render json: @board_member.errors, status: :unprocessable_entity
    end
  end

  private

  def member_params
    params.fetch(:board_member, {}).permit(:role)
  end

end