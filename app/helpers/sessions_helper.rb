module SessionsHelper
  
  def log_in(user)
    cookies.permanent.signed[:remember_token] = [user.id, user.salt]
    current_user = user
  end
  
  def current_user=(user)
    @current_user = user
  end
  
  def current_user
    @current_user ||= user_from_remember_token
  end
  
  def logged_in?
    !current_user.nil?
  end
  
  def log_out
    cookies.delete(:remember_token)
    current_user = nil
  end
  
  def current_user?(user)
    user == current_user
  end
  
  def deny_access
    store_location
    redirect_to login_path, :notice => "Please log in to access this page."
  end
  
  def legality_warning
    redirect_to root_path, :notice => "Permission denied"
  end
  
  def admin_user
    unless current_user.admin?
      flash[:notice]="Permission denied"
      redirect_to(root_path)
    end
  end
  
  def vendor_user
    unless current_user.vendor?
      flash[:notice] = "If you want to sell training, then you need to modify your 'Settings' page."
      redirect_to user_path(current_user)
    end
  end
  
  def current_vendor
    if current_vendor?
      Vendor.find(cookies[:vendor_id])
    else
      return nil
    end
  end
  
  def current_vendor?
    !cookies[:vendor_id].nil?
  end
  
  def store_location
    session[:return_to] = request.fullpath
  end
  
  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
  end
  
  def clear_return_to
    session[:return_to] = nil
  end
  
  def select_home_path
    if logged_in?
      if current_user.vendor?
        redirect_to business_home_path
      elsif current_user.admin?
        redirect_to admin_home_path
      else
        redirect_to root_path  
      end
    else
      redirect_to login_path
    end
  end
  
  private
  
    def user_from_remember_token
      User.authenticate_with_salt(*remember_token)
    end
    
    def remember_token
      cookies.signed[:remember_token] || [nil, nil]
    end
    
    def authenticate
      deny_access unless logged_in?
    end
    
    def legality_check
      if logged_in?
        legality_warning unless current_user.admin?
      else
        legality_warning
      end
    end
    
    def vendor_legality_check
      if logged_in?
        legality_warning unless current_user.vendor?
      else
        legality_warning
      end
    end
end
