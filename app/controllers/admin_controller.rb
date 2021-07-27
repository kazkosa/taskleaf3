class AdminController < ApplicationController
  include Admin::SessionsHelper
  layout "application_admin"

  def index
    redirect_to(root_url) unless admin_logged_in?
  end

  private

  # If you are not logged in, redirect to the login screen
  def logged_in_manager
    unless admin_logged_in?
      redirect_to root_url
    end
  end

end
