class Admin::StatesController < AdminController
  layout "application_admin"
  before_action :logged_in_manager
  before_action :set_state, only: [:show,:destroy,:edit,:update]

  def index
    @states = State.all 
  end

  def new
    @state = State.new
  end

  def create
    @state = State.new(state_params)

    if @state.save
      flash[:success] = "State Created!"
      if (params[:state][:from_board_id])
        redirect_to admin_board_url(params[:state][:from_board_id].to_i)
      else
        redirect_to admin_state_url(@state)
      end
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    @state.update(state_params)
    redirect_to admin_state_url(@state)
  end

  def show
  end

  def destroy
    @state.destroy
    redirect_to action: :index
  end

  private
  def state_params
    params.require(:state).permit(:board_id, :name, :sort)
  end
  def set_state
    @state = State.find(params[:id])
  end
end
