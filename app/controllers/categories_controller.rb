class CategoriesController < ApplicationController
  
  
  def index
    val = params[:id]
    @title = "Training categories => #{Category.display_aim(val.to_i)}" 
  end

  def new
  end

end
