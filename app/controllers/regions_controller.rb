class RegionsController < ApplicationController
  
  before_filter :authenticate,    :except => [:create, :update]
  before_filter :legality_check,  :only   => [:create, :update]
  before_filter :admin_user
  
  def index
    @title = "Regions"
    @regions = Region.all(:order => "region")
  end

  def new
    @title = "New region"
    @region = Region.new
    @tag_name = "Create"
  end
  
  def create
    @region = Region.new(params[:region])
    if @region.save
      flash[:success] = "Region created."
      redirect_to regions_path
    else
      @title = "New region"
      render 'new'
    end
  end
  
  def edit
    @title = "Edit region"
    @region = Region.find(params[:id])
    @tag_name = "Confirm changes"
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
    @region = Region.find(params[:id])
    @name = @region.region
    if @region.has_countries?
      flash[:error] = "Cannot delete #{@name} - linked to countries."
    else
      @region.destroy
      flash[:success] = "#{@name} deleted."
    end
    redirect_to(regions_path)
  end

end
