module Admin::SessionsHelper
  # Login by inputing manager
  def admin_log_in(manager)
    session[:manager_id] = manager.id
  end

  # Returns the manager if logged in
  def current_manager
    if session[:manager_id]
      @current_manager ||= Manager.find_by(id: session[:manager_id])
    end
  end

  # Returns true if the manager is logged in, false otherwise
  def admin_logged_in?
    !current_manager.nil?
  end

  # Current manager logout
  def admin_log_out
    session.delete(:manager_id)
    @current_manager = nil
  end
end
