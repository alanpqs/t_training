class RegionsController < ApplicationController
  
  before_filter :authenticate
  before_filter :admin_user
  
  def index
    @title = "Regions"
    @regions = Region.all
  end

  def new
    @title = "New region"
    @region = Region.new
  end
  
  def create
    if @region = Region.create(params[:region])
      flash[:success] = "Region created."
      redirect_to regions_path
    else
      @title = "New region"
      render 'new'
    end
  end
  
  def show
    @title = "Region"
  end
  
  def edit
    @title = "Edit region"
    @region = Region.find(params[:id])
  end
  
  def update
    @region = Region.find(params[:id])
    if @region.update_attributes(params[:region])
      flash[:success] = "Region updated."
      redirect_to regions_path
    else
      @title = "Edit region"
      render 'edit'
    end
  end
  
  def destroy
    Region.find(params[:id]).destroy
    flash[:success] = "Region destroyed."
    redirect_to(regions_path)
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
