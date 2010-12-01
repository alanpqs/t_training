class CitiesController < ApplicationController
  
  before_filter :authenticate
  
  def index
  end

  def new
    @country = Country.find(params[:country_id])
    @city = City.new
    @title = "New city in #{@country.name}"
    @tag_name = "Create"
  end

  def create
    @country = Country.find(params[:country_id])
    @city = @country.cities.new(params[:city])
    if @city.save
      flash[:success] = "#{@city.name} has been added."
      if current_user.admin?
        redirect_to admin_country_path(@country)  
      else
        redirect_to country_cities_path(@country)
      end
    else
      @title = "New city in #{@country.name}"
      @tag_name = "Create"
      render 'new'
    end
  end
end
