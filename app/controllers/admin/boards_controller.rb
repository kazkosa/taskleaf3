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
    @states = @board.states.order("states.sort")
  end

  def edit
    @board = Board.find(params[:id])
    @members = @board.build_member
    @states = @board.states.order("states.sort")
  end

  def update
    @board = Board.find(params[:id])
    @states = @board.states.order("states.sort")
 
    target_delete_members = @board.diff_member(board_params[:user_ids])
 
    if board_params[:user_ids] && @board.check_member(board_params[:project_id], board_params[:user_ids], board_member_params[:roles]) && @board.update(board_params) && @board.delete_child(target_delete_members) && @board.update_states(board_params[:state_ids]) && @board.update_tasks(task_params[:task_ids]) && @board.update_members(board_params[:user_ids], board_member_params[:roles])
      flash[:success] = "Board Updated"
      redirect_to admin_board_url(@board)
    else
      @members = @board.build_member
      render 'edit'
    end
  end

  def destroy
    Board.find(params[:id]).destroy
    redirect_to admin_boards_url
  end

  private

  def board_params
    params.require(:board).permit(:project_id, :name, :description, user_ids: [], state_ids: [] )
  end

  def board_member_params
    params.require(:board_member).permit(roles: [])
  end

  def task_params
    params.require(:board).permit(task_ids: {})
  end

end
