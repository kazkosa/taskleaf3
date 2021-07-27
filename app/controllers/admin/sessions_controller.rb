class Admin::SessionsController < AdminController
  layout "login"
  def new
  end

  def create
    manager = Manager.find_by(login_id: params[:session][:login_id])
    if manager && manager.authenticate(params[:session][:password])
      admin_log_in manager
      redirect_back_or admin_url
    else
      flash[:danger] = 'Invalid account id/password combination'
      render 'new'
    end
  end

  def destroy
    admin_log_out if admin_logged_in?

    redirect_to root_url
  end
end
