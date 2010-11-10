class CountriesController < ApplicationController
  
  before_filter :authenticate,    :only   => [:index, :edit, :show]
  before_filter :legality_check,  :only   => [:create, :update]
  before_filter :admin_user,      :only   => [:index, :edit, :show]  
  
  def index
    @title = "Countries"
    @countries = Country.paginate(:page => params[:page],
                                  :order => :name)
  end

  def show
    @country = Country.find(params[:id])
    @title = @country.name
  end
  
  def new
    @title = "New country"
    @country = Country.new
    @tag_name = "Create"
  end

  def create
    @country = Country.new(params[:country])
    if @country.save
      flash[:success] = "Country created."
      redirect_to countries_path
    else
      @title = "New country"
      @tag_name = "Create"
      render 'new'
    end
  end

  def edit
    @country = Country.find(params[:id])
    @title = "Edit #{@country.name}"
    @tag_name = "Confirm changes"
    #@currencies = Money::Currency::TABLE.sort_by { |k,v| v[:iso_code] }
  end

  def update
    @country = Country.find(params[:id])
    if @country.update_attributes(params[:country])
      flash[:success] = "#{@country.name} updated."
      redirect_to country_path
    else
      if @country.name.nil?
        @title = "Edit country"
      else
        @title = "Edit #{@country.name}"
      end
      @tag_name = "Confirm changes"
      render 'edit'
    end
  end

  def destroy
    @country = Country.find(params[:id])
    @country_name = @country.name
    @country.destroy
    flash[:success] = "#{@country_name} deleted."
    redirect_to(countries_path)
  end

end
