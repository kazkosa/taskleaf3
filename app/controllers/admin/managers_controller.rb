# class Admin::ManagersController < ApplicationController
class Admin::ManagersController < AdminController
  layout "application_admin"
  before_action :logged_in_manager
  def index
    @managers = Manager.all
  end

  def new
    @manager = Manager.new 
  end

  def create
    @manager = Manager.new(manager_params)
    if @manager.save
      flash[:success] = "Welcome to the TicketLine!"
      redirect_to admin_manager_url(@manager)
    else
      render 'new'
    end
  end

  def show
    @manager = Manager.find(params[:id])
  end

  def edit
    @manager = Manager.find(params[:id])
  end

  def update
    @manager = Manager.find(params[:id])
    if @manager.update_attributes(manager_params)
      flash[:success] = "Profile updated"
      redirect_to admin_manager_url(@manager)
    else
      render 'edit'
    end
  end
  def destroy
    Manager.find(params[:id]).destroy
    redirect_to admin_managers_url
  end
  private
  
  def manager_params
    params.require(:manager).permit(:login_id, :admin, :password, :password_confirmation)
  end

end
