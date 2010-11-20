class CategoriesController < ApplicationController
  
  
  def index
    @target = params[:id]
    @title = "Training categories => #{@target}" 
  end

  def new
  end

end
