class Admin::CountriesController < ApplicationController
  
  before_filter :authenticate,    :only   => [:index, :new, :edit, :show, :destroy]
  before_filter :legality_check,  :only   => [:create, :update]
  before_filter :admin_user,      :only   => [:index, :edit, :new, :show, :destroy]  
  
  def index
    @title = "Countries"
    @countries = Country.paginate(:page => params[:page],
                                  :order => :name)
  end

  def show
    @country = Country.find(params[:id])
    @title = @country.name
    @cities = @country.cities.all(:order => "name")
  end
  
  def new
    @title = "New country"
    @country = Country.new
    @regions = Region.find(:all, :order => "region")
    @tag_name = "Create"
  end

  def create
    @country = Country.new(params[:country])
    if @country.save
      flash[:success] = "New country created."
      redirect_to admin_country_path(@country)
    else
      @title = "New country"
      @regions = Region.find(:all, :order => "region")
      @tag_name = "Create"
      render 'new'
    end
  end

  def edit
    @country = Country.find(params[:id])
    @regions = Region.find(:all, :order => "region")
    @title = "Edit #{@country.name}"
    @tag_name = "Confirm changes"
    #@currencies = Money::Currency::TABLE.sort_by { |k,v| v[:iso_code] }
  end

  def update
    @country = Country.find(params[:id])
    if @country.update_attributes(params[:country])
      flash[:success] = "#{@country.name} updated."
      redirect_to admin_country_path(@country)
    else
      if @country.name.empty?
        @title = "Edit country"
      else
        @title = "Edit #{@country.name}"
      end
      @regions = Region.find(:all, :order => "region")
      @tag_name = "Confirm changes"
      render "edit"
    end
  end

  def destroy
    @country = Country.find(params[:id])
    @country_name = @country.name
    @country.destroy
    flash[:success] = "#{@country_name} deleted."
    redirect_to(admin_countries_path)
  end

end
