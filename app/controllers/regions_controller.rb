class RegionsController < ApplicationController
  
  before_filter :authenticate
  before_filter :admin_user
  
  def index
    @title = "Regions"
    @regions = Region.all
  end

  def new
  end

  private
  
    def authenticate
      deny_access unless logged_in?
    end
    
    def admin_user
      unless current_user.admin?
        flash[:notice]="Permission denied"
        redirect_to(root_path)
      end
    end
    
end
