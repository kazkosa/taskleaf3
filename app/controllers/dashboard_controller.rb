class DashboardController < ApplicationController
  layout "application_dashboard"
  before_action :logged_in_user, only: :index
  def index
  end

  private


  # If you are not logged in, redirect to the login screen
  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "Please log in."
      redirect_to login_url
    end
  end
end
