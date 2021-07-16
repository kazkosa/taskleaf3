class UsersController < ApplicationController
  layout 'login', only: [:new, :create]
  def index
    @users = User.all
  end
  def new
    # render :layout => "login"
    @user = User.new 
  end
  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "Welcome to the Task Leaf!"
      redirect_to @user
    else
      render 'new'
    end
  end
  def show
    @user = User.find(params[:id])
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

end
