class Admin::CitiesController < ApplicationController
  
  before_filter :authenticate,    :except => :update   
  before_filter :legality_check,  :only   => :update
  before_filter :admin_user,      :except => :update     
  
  def index
    @title = "New cities added"
    @cities = City.no_geolocation
  end

  def edit
    @city = City.find(params[:id])
    @title = "Edit city details"
    @tag_name = "Confirm changes"
    @country = Country.find(@city.country_id)
    @cities = @country.cities.all(:order => "name")
  end
  
  def update
    @city = City.find(params[:id])
    if @city.update_attributes(params[:city])
      flash[:success] = "#{@city.name} successfully updated"
      redirect_to admin_cities_path
    else
      @title = "Edit city details"
      @tag_name = "Confirm changes"
      @country = Country.find(@city.country_id)
      @cities = @country.cities.all(:order => "name")
      render "edit"
    end
  end
  
  def destroy
    @city = City.find(params[:id])
    @city_name = @city.name
    @city.destroy
    flash[:success] = "#{@city_name} has been deleted."
    redirect_to admin_cities_path
  end
end
