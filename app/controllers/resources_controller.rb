class ResourcesController < ApplicationController
  
  before_filter :authenticate#,            :except => [:create, :update]    
  #before_filter :vendor_legality_check,   :only   => [:create, :update]
  before_filter :vendor_user#,             :except => [:create, :update]   
  
  def index
    @title = "Resources"
    @tag_name = "Add a new resource"
    @vendor = current_vendor
  end

  def new
    
    if params[:group].blank?
      flash[:error] = "You didn't select a group.  Please try again."
      redirect_to resource_group_path
    else
      @title = "New resource"
      @vendor = current_vendor
      @group = params[:group]
      @resource = Resource.new
      @categories = Category.all_authorized_by_target(@group)
      @media = Medium.all_authorized
      @tag_name = "Create"
    end 
  end

end
