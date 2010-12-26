class Business::PagesController < ApplicationController
  
  before_filter :authenticate#,    :except => [:create, :update]    
  #before_filter :legality_check,  :only   => [:create, :update]
  before_filter :vendor_user#,     :except => [:create, :update]   
  
  def home
    @user = current_user
    @title = "Training supplier - home"
    cookies[:vendor_id] = @user.get_single_company_vendor   #set to nil unless only one associated company    
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
    
  end
  
  def duplicate_resource to_group
    
  end
  
  def move_resource_to_group
    
  end
  
  def new_resource_same_group
    
  end
end
