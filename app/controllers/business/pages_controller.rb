class Business::PagesController < ApplicationController
  
  before_filter :authenticate#,    :except => [:create, :update]    
  #before_filter :legality_check,  :only   => [:create, :update]
  before_filter :vendor_user#,     :except => [:create, :update]   
  before_filter :correct_vendor_user
  
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
      :description => @attr_resource.description, :webpage => @attr_resource.webpage,
      :feature_list => @attr_resource.feature_list)
    cookies[:vendor_id] = @vendor.id
    flash[:success] = "This resource has been successfully duplicated - but you may now 
      need to edit your webpage reference.  Note that you are now working with the 
      #{@vendor.name} menu."
    redirect_to resource_path(@resource)
  end
  
  def resource_activation
    @title = "Opening for business"
    @vendor = Vendor.find(cookies[:vendor_id])
    
  end
  
  def keyword_help
    @title = "Keyword help"
  end
  
  def popular_keywords
    @category = Category.find(cookies[:category_id])
    @title = "Popular keywords: #{@category.category}"
    @tags = @category.resources.tag_counts_on(:features)
    tag_cloud(@category)
  end
  
  def tag_cloud(category)
    @tags = category.resources.tag_counts_on(:features)
  end
  
  def select_category
    @group = (cookies[:group_name])
    @title = "Select category: #{@group}"
    @categories = Category.all_authorized_by_target(@group)
    @tag_name = "Now click to view popular keywords"
  end
  
  def category_selected
    @category = Category.find(params[:category])
    cookies[:category_id] = @category.id
    redirect_to :popular_keywords
  end
  
  def tickets_menu
    @title = "Tickets for Training"
    @vendor = Vendor.find(current_vendor)
  end
  
  def t4t_intro
    @title = "Effective marketing with T4T"
  end
  
  def program_selection
    @vendor = Vendor.find(current_vendor)
    if @vendor.no_tickets?
      flash[:notice] = "You've applied to issue tickets, but you've used all your ticket credits.
        To continue, please place an order for more tickets."
      redirect_to vendor_account_path
    else
      @title = "Ticket issue: select an event"
      @items = Item.ticketable_events(@vendor)
    end
  end
  
  def resource_selection
    @vendor = Vendor.find(current_vendor)
    @title = "Ticket issue: select a resource"
    @items = Item.ticketable_resources(@vendor)
  end
  
  def vendor_account
    @vendor = Vendor.find(current_vendor)
    @title = "Your 'Tickets' account"
  end
end
