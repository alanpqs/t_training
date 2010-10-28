class RegionsController < ApplicationController
  
  def index
    @title = "Regions"
    @regions = Region.all
  end

  def new
  end

end
