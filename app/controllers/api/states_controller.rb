class Api::StatesController < ApplicationController
  before_action :set_state, only: [:show, :update, :destroy]
  skip_before_action :verify_authenticity_token

  def index
    @states = State.where(board_id: params[:board_id]).order("states.sort")

    # state.tasks.order("tasks.sort")
  end

  def create
    @state = State.new(state_params)
    @states = State.where(board_id: @state.board_id).order("states.sort")
    @state.sort = @states? @states.length : 0
    if @state.save
      @states = State.where(board_id: @state.board_id).order("states.sort")
      render :index, status: :created
    else
      render json: @state.errors, status: :unprocessable_entity
    end
  end

  def show
  end

  def update
    if @state.update_attributes(state_params)
      render :show, status: :created
    else
      render json: @state.errors, status: :unprocessable_entity
    end
  end

  def destroy
    if @state.destroy
      head :no_content
    else
      render json: @state.errors, status: :unprocessable_entity
    end
  end

  private

  def state_params
    params.require(:state).permit(:board_id, :name, :sort)
  end

  def set_state
    @state = State.find(params[:id])
  end

end