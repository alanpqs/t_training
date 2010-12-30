class Business::PagesController < ApplicationController
  
  before_filter :authenticate#,    :except => [:create, :update]    
  #before_filter :legality_check,  :only   => [:create, :update]
  before_filter :vendor_user#,     :except => [:create, :update]   
  
  def home
    @user = current_user
    @title = "Training supplier - home"
    cookies[:vendor_id] = @user.get_single_company_vendor   #set to blank unless only one associated company    
  end

  def resource_group
    @user = current_user
    unless cookies[:vendor_id].blank?
      @vendor = Vendor.find(cookies[:vendor_id])
      @title = "New resource - select a group"
      @tag_name = "Confirm"
      @targets = Category::TARGET_TYPES
    else
      if @user.vendors.count == 0
        flash[:error] = "First you need to add at least one vendor business."
      else
        flash[:error] = "First you need to select one of your vendor businesses."
      end
      redirect_to business_home_path
    end 
  end
  
  def duplicate_resource_to_vendor
    if cookies[:resource_id].blank?
      redirect_to business_home_path
    else
      @resource = Resource.find(cookies[:resource_id])
      @title = "Duplicate resource to vendor"
      @with_resource = []
      @without_resource = []
      @user = current_user
      @vendors = @user.vendors
      @vendors.each do |vendor|
        if vendor.has_resource?("#{@resource.name}")
          @with_resource << vendor
        else
          @without_resource << vendor
        end
      end
    end
  end
  
  def duplicate_to_vendor
    @attr_resource = Resource.find(cookies[:resource_id])
    @vendor = Vendor.find(params[:id])
    @resource = Resource.create(:name => @attr_resource.name, :vendor_id => @vendor.id, 
      :category_id => @attr_resource.category_id, :medium_id => @attr_resource.medium_id,
      :length_unit => @attr_resource.length_unit, :length => @attr_resource.length,
      :description => @attr_resource.description, :webpage => @attr_resource.webpage)
    cookies[:vendor_id] = @vendor.id
    flash[:success] = "This resource has been successfully duplicated - but you may now 
      need to edit your webpage reference.  Note that you are now working with the 
      #{@vendor.name} menu."
    redirect_to resource_path(@resource)
  end
  
end
