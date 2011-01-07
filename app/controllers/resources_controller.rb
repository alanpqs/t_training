class ResourcesController < ApplicationController
  
  before_filter :authenticate,            :except => [:create, :update]    
  before_filter :user_authorization,      :only   => [:show, :edit, :update, :destroy]
  before_filter :vendor_legality_check,   :only   => [:create]
  before_filter :vendor_user,             :only => [:index, :new]
    
  
  def index
    @title = "Resources"
    @tag_name = "Add a new resource"
    @vendor = Vendor.find(current_vendor)
    @resources = @vendor.resources.paginate(:page => params[:page],
                                  :order => :name)
    @users = User.paginate(:page => params[:page])


  end

  def new
    if params[:group].blank?
      flash[:error] = "You didn't select a group.  Please try again."
      redirect_to resource_group_path
    else
      @title = "New resource"
      @vendor = current_vendor
      @group = params[:group]
      cookies[:group_name] = @group
      cookies[:category_id] = nil
      @resource = Resource.new
      @categories = Category.all_authorized_by_target(@group)
      @media = Medium.all_authorized
      @tag_name = "Create"
      store_location
    end 
  end

  def create
    @vendor = Vendor.find(params[:vendor_id])
    @resource = @vendor.resources.new(params[:resource])
    @group = cookies[:group_name]
    if @resource.save
      flash[:success] = "This #{@vendor.name} resource has been successfully created."
      redirect_to @resource
    else
      @title = "New resource"
      @categories = Category.all_authorized_by_target(@group)
      @media = Medium.all_authorized
      @tag_name = "Create"
      render "new"  
    end
  end
  
  def show
    @resource = Resource.find(params[:id])
    @vendor = Vendor.find(@resource.vendor_id)
    @title = @resource.name
    #resource_cookie(@resource.id)
    cookies[:resource_id] = @resource.id
  end
  
  def edit
    @resource = Resource.find(params[:id])
    @tag_name = "Confirm changes"
    @title = "Edit resource"
    @vendor = Vendor.find(@resource.vendor_id)
    @group = Category.find(@resource.category_id).in_group
    cookies[:group_name] = @group
    cookies[:category_id] = @resource.category_id
    @categories = Category.all_authorized_by_target(@group)
    @media = Medium.all_authorized
    store_location
  end
  
  def update
    @resource = Resource.find(params[:id])
    if @resource.update_attributes(params[:resource])
      flash[:success] = "Your resource was successfully updated."
      redirect_to @resource
    else
      @tag_name = "Confirm changes"
      @title = "Edit resource"
      @vendor = Vendor.find(current_vendor)
      @group = cookies[:group_name]
      @categories = Category.all_authorized_by_target(@group)
      @media = Medium.all_authorized
      render "edit"
    end
  end
  
  def destroy
    @resource = Resource.find(params[:id])
    @vendor = Vendor.find(@resource.vendor_id)
    @resource_name = @resource.name
    @resource.destroy
    flash[:success] = "'#{@resource_name}' deleted."
    redirect_to(vendor_resources_path(@vendor))
  end
  
  private
  
    def user_authorization
      msg = "You're trying to access an area that does not belong to you.  Please don't!!"
      if logged_in?
        @resource = Resource.find(params[:id])
        @vendor = Vendor.find(@resource.vendor_id)
        unless @vendor.is_associated_with?(current_user.id)
          flash[:error] = msg
          select_home_path
        end
      else
        flash[:error] = msg
        redirect_to root_path
      end
    end
end
