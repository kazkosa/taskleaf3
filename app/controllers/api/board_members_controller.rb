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
    tasks = Task.where({
      board_id: @board_member.board_id,
      user_id: @board_member.user_id
    })
    if tasks
      tasks.each do |task|
        task.user_id = nil
        task.save
      end
    end
    if @board_member.destroy
      head :no_content
    else
      render json: @board_member.errors, status: :unprocessable_entity
    end
  end

  def show
    @board_member = BoardMember.find(params[:id])
    if @board_member
      render :show
    else
      render json: { errors: { title: 'レコードが見つかりません', detail: 'IDと一致するレコードが見つかりません' }, status: :not_found }
    end
  end

  def search
    @board_member = BoardMember.find_by(user_id: params[:user_id], board_id: params[:board_id])
    if @board_member
      render :show
    else
      render json: { errors: { title: 'レコードが見つかりません', detail: 'IDと一致するレコードが見つかりません' }, status: :not_found }
    end
  end


  private

  def member_params
    params.fetch(:board_member, {}).permit(:role)
  end

end