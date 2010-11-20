class Admin::CategoriesController < ApplicationController
  
  before_filter :authenticate    
  #before_filter :legality_check,  :only   => [:create, :update]
  before_filter :admin_user      
  
  
  def index
    @target = params[:id]
    @title = "Training categories => #{@target}" 
  end

  def new
    @target = params[:id]
    @title = "New #{@target} category"
    @category = Category.new(:target => @target, :user_id => current_user.id)
    @tag_name = "Create"
  end
  
  def create
    @category = Category.new(params[:category])
    @target = @category.target
    if @category.save
      flash[:success] = "New category created."
      redirect_to admin_categories_path(:id => @target)
    else
      @title = "New #{@target} category"
      @tag_name = "Create"
      render 'new'
    end
  end
end
