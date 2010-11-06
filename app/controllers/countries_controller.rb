class CountriesController < ApplicationController
  
  def index
    @title = "Countries"
    @countries = Country.all(:order => "name")
  end

  def show
    @country = Country.find(params[:id])
    @title = @country.name
  end
  
  def new
    @title = "New country"
    @region = Country.new
    @tag_name = "Create"
  end

  def create
    @country = Country.new(params[:country])
    if @country.save
      flash[:success] = "Country created."
      redirect_to countries_path
    else
      @title = "New country"
      render 'new'
    end
  end

  def edit
    @title = "Edit country"
    @region = Country.find(params[:id])
    @tag_name = "Confirm changes"
  end

  def update
    @country = Country.find(params[:id])
    if @country.update_attributes(params[:country])
      flash[:success] = "Country updated."
      redirect_to countries_path
    else
      @title = "Edit country"
      render 'edit'
    end
  end

  def destroy
    Country.find(params[:id]).destroy
    flash[:success] = "Country destroyed."
    redirect_to(countries_path)
  end

end
