class ResourcesController < ApplicationController
  
  before_filter :authenticate,            :except => [:create]    
  before_filter :vendor_legality_check,   :only   => [:create]
  before_filter :vendor_user,             :except => [:create]
    
  
  def index
    @title = "Resources"
    @tag_name = "Add a new resource"
    @vendor = current_vendor
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
      @resource = Resource.new
      @categories = Category.all_authorized_by_target(@group)
      @media = Medium.all_authorized
      @tag_name = "Create"
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
  end
  
  def edit
    @resource = Resource.find(params[:id])
    @tag_name = "Confirm changes"
    @title = "Edit resource"
    @vendor = Vendor.find(@resource.vendor_id)
    @group = Category.find(@resource.category_id).in_group
    cookies[:group_name] = @group
    @categories = Category.all_authorized_by_target(@group)
    @media = Medium.all_authorized
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
    flash[:success] = "#{@resource_name} deleted."
    redirect_to(vendor_resources_path(@vendor))
  end
end
