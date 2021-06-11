class TrialsController < ApplicationController
  before_action :set_trial, only: [:show,:destroy,:edit,:update]
  def index
    @trials = Trial.all 
  end

  def new
    @trial = Trial.new
  end

  def create
    # binding.pry
    @trial = Trial.new(trial_params)

    if @trial.save
      redirect_to trials_path
    else
      render :new
    end
  end

  def edit
  end

  def update
    @trial.update(trial_params)
    redirect_to trials_path
  end

  def show
  end

  def destroy
    @trial.destroy
    redirect_to action: :index
  end

  private
  def trial_params
    params.require(:trial).permit(:title, :body)
  end
  def set_trial
    @trial = Trial.find(params[:id])
  end
end
