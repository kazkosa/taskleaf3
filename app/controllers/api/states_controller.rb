class Api::StatesController < ApplicationController
  # skip_before_action :verify_authenticity_token

  def index
    @states = State.where(board_id: params[:board_id]).order("states.sort")
  end

end