class Business::VendorsController < ApplicationController
  
  before_filter :authenticate,            :except => [:create, :update]    
  before_filter :vendor_legality_check,   :only   => [:create, :update]
  before_filter :vendor_user,             :except => [:create, :update]   
  
  def index
  end

  def new
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
      UserMailer.vendor_confirmation(@vendor).deliver
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
  
  def show
    @vendor = Vendor.find(params[:id])
    @title = @vendor.name
  end
end
