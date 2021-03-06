module SessionsHelper
  
  def log_in(user)
    cookies.permanent.signed[:remember_token] = [user.id, user.salt]
    current_user = user
  end
  
  def vendor_cookie(user)
    if user.single_company_vendor?
      cookies[:vendor_id] = user.get_single_company_vendor
    end
  end
  
  def selected_vendor_cookie(vendor)
    cookies[:vendor_id] = vendor
  end
  
  def resource_cookie(resource)
    cookies[:resource_id] = resource
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
    flash[:notice] = "Please log in to access this page."
    redirect_to login_path
  end
  
  def legality_warning
    flash[:notice] = "Permission denied"
    redirect_to root_path
  end
  
  def admin_user
    unless current_user.admin?
      flash[:notice]="Permission denied"
      redirect_to root_path
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
    !cookies[:vendor_id].blank?
  end
  
  def current_resource
    if current_resource?
      Resource.find(cookies[:resource_id])
    end
  end
  
  def current_resource?
    !cookies[:resource_id].blank?
  end
  
  def store_location
    session[:return_to] = request.fullpath
  end
  
  def store_resource
    session[:return_to_resource] = request.fullpath
  end
  
  def store_search
    session[:return_to_search] = request.fullpath
  end
  
  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
  end
  
  def clear_return_to
    session[:return_to] = nil
  end
  
  def clear_search_sessions
    session[:return_to_search] = nil
    session[:return_to_resource] = nil
  end
  
  def select_home_path
    if logged_in?
      if current_user.vendor?
        redirect_to business_home_path
      elsif current_user.admin?
        redirect_to admin_home_path
      else
        redirect_to user_path(current_user) 
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
    
    def member_legality_check
      unless logged_in?
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
    
    def correct_vendor_user
      #if logged_in?
        #if current_user.vendor?
          if current_vendor?
            @nmbr = Representation.count(:all, 
                    :conditions => ["user_id =? and vendor_id =?", current_user.id, current_vendor.id])
            if @nmbr == 0
              legality_warning
            end
          end
        #end
      #end
    end
end
