class Admin::BoardsController < AdminController
  layout "application_admin"
  before_action :logged_in_manager
  # rescue_from ActiveRecord::RecordNotFound, with: :redirect_to_projects

  def index
    @boards = Board.all
  end

  def new
    @board = Board.new
    @board.board_members.build
    @members = []
  end

  def create
    @board = Board.new(board_params)
    @board.board_members.each_with_index do |member, index|
      member.role = (board_member_params[:roles][index]).to_i
    end
    if @board.save
      flash[:success] = "Board Created!"
      redirect_to admin_board_url(@board)
    else
      render 'new'
    end
  end

  def show
    @board = Board.find(params[:id])
  end

  def edit
    @board = Board.find(params[:id])
    @members = @board.build_member
  end

  def update
    @board = Board.find(params[:id])

    if @board.update(board_params) && @board.ensure_no_member
      success = true
      if board_params[:user_ids]
        @board.board_members.each do |member|
          index = board_params[:user_ids].index(member.user_id.to_s)
          member.role = (board_member_params[:roles][index]).to_i
          unless member.save
            success = false
          end
        end
      end
      if success
        flash[:success] = "Board Updated"
        redirect_to admin_board_url(@board)
      else
        render 'edit'
      end
    else
      render 'edit'
    end
  end
  def destroy
    Board.find(params[:id]).destroy
    redirect_to admin_boards_url
  end

  private

  def board_params
    params.require(:board).permit(:project_id, :name, :description, user_ids: [] )
  end

  def board_member_params
    params.require(:board_member).permit(roles: [])
  end

end
