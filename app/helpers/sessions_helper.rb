module SessionsHelper
  # Login by inputing user
  def log_in(user)
    session[:user_id] = user.id
  end

  # Make the user's session permanet
  def remember(user)
    user.remember # update DB attribute(remember_digest) for persistent sessions (Definited in User.rb)
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # Returns the user if logged in
  def current_user
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # Returns true if the user is a logged-in
  def current_user?(user)
    user == current_user
  end

  # Returns true if the user is logged in, false otherwise
  def logged_in?
    !current_user.nil?
  end

  # Delete cookies
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # Current user logout
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end

  # Redirect to the memorized URL (or default value)
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  # Remember the URL user tried to access
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end

end
