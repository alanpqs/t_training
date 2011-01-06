class Business::VendorsController < ApplicationController
  
  before_filter :authenticate,            :except => [:create, :update]    
  before_filter :user_authorization,      :only   => [:show, :edit, :update, :destroy]
  before_filter :vendor_legality_check,   :only   => [:create]
  before_filter :vendor_user,             :only   => [:index, :new]   
  
  
  def index
  end

  def show
    @vendor = Vendor.find(params[:id])
    selected_vendor_cookie(@vendor.id)
    #cookies[:vendor_id] = @vendor.id
    @title = @vendor.name
  end
  
  def new
    cookies[:vendor_id] = nil
    @title = "New vendor"
    @user = current_user
    @vendor = Vendor.new
    @vendor.country_id = @user.country_id
    @countries = Country.find(:all, :order => "name")
    @tag_name = "Create"
  end

  def create
    @vendor = Vendor.new(params[:vendor])
    @user = current_user
    @vendor.verification_code = @vendor.generated_verification_code
    if @vendor.save
      Representation.create(:user_id => @user.id, :vendor_id => @vendor.id)
      cookies[:vendor_id] = @vendor.id
      VendorMailer.vendor_confirmation(@vendor).deliver
      flash[:success] = "#{@vendor.name} has been created, and will be activated after email confirmation."
      redirect_to business_vendor_path(@vendor)
    else
      @title = "New vendor"
      @user = current_user
      @vendor.country_id = @user.country_id
      @countries = Country.find(:all, :order => "name")
      @tag_name = "Create"
      render "new"
    end
  end
  
  def edit
    @vendor = Vendor.find(params[:id])
    @title = "Edit vendor"
    @tag_name = "Save changes"
    @countries = Country.find(:all, :order => "name")
  end
  
  def update
    @vendor = Vendor.find(params[:id])
    if @vendor.update_attributes(params[:vendor])
      flash[:success] = "Vendor updated."
      redirect_to business_vendor_path(@vendor)
    else
      @title = "Edit vendor"
      @tag_name = "Save changes"
      @countries = Country.find(:all, :order => "name")
      render "edit"
    end     
  end
  
  private
  
    def user_authorization
      msg = "You're trying to access an area that does not belong to you.  Please don't!!"
      if logged_in?
        @vendor = Vendor.find(params[:id])
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
