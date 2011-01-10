class Business::CategoriesController < ApplicationController
  
  before_filter :check_login,             :only => :new           
  before_filter :vendor_user,             :only => :new
  before_filter :vendor_legality_check,   :only =>  :create 
  
  def new
    @title = "Suggest a new category"
    @group = cookies[:group_name]
    @category = Category.new
    @category.user_id = current_user.id
    @category.target = @group
    #@category.submitted_group = @group
    @tag_name = "Send your suggestion"
    @categories = Category.find(:all, :conditions => ["target = ?", @group],:order => "category")
  end

  def create
    @category = Category.new(params[:category])
    if @category.save
      flash[:success] = "You've proposed a new category - '#{@category.category}'. We'll respond soon by email."
      redirect_to session[:return_to]
    else
      @title = "Suggest a new category"
      @tag_name = "Send your suggestion"
      @category.user_id = current_user.id
      @categories = Category.find(:all, :conditions => ["target = ?", @group],:order => "category")
      render 'new'
    end
  end
  
  private
  
    def check_login
      unless logged_in?
        flash[:notice] = "You must be logged in for the action you requested"
        redirect_to login_path
      end
    end
end
