class Admin::CategoriesController < ApplicationController
  
  before_filter :authenticate    
  #before_filter :legality_check,  :only   => [:create, :update]
  before_filter :admin_user      
  
  
  def index
    @topic = params[:id]
    @title = "Training categories => #{@topic}" 
  end

  def new
    @topic = params[:id]
    @title = "New #{@topic} category"
    aim_id = Category.aims_index(@topic)
    @category = Category.new(:aim => aim_id, :user_id => current_user.id)
    @tag_name = "Create"
  end
  
  def create
    @category = Category.new(params[:category])
    @topic_id = @category.aim
    @topic = @category.training_aim
    if @category.save
      flash[:success] = "New category created."
      redirect_to admin_categories_path(:id => @topic)
    else
      @title = "New #{@topic} category"
      @tag_name = "Create"
      render 'new'
    end
  end
end
