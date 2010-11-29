class Admin::CategoriesController < ApplicationController
  
  before_filter :authenticate,    :except => [:create, :update]    
  before_filter :legality_check,  :only   => [:create, :update]
  before_filter :admin_user,      :except => [:create, :update]      
  
  
  def index
    @target = params[:id]
    @title = "Training categories => #{@target}" 
    @categories = Category.all_authorized_by_target(@target).paginate(:page => params[:page])
    @other_groups = Category.list_groups_except(@target)
  end

  def new
    @target = params[:id]
    @title = "New #{@target} category"
    @category = Category.new(:target => @target, :user_id => current_user.id)
    @tag_name = "Create"
  end
  
  def create
    @category = Category.new(params[:category])
    @content = @category.category
    @target = @category.target
    @category.submitted_name = @content
    @category.submitted_group = @target
    
    if @category.save
      flash[:success] = "'#{@content}' now needs to be authorized before appearing on the public list."
      redirect_to admin_categories_path(:id => @target)
    else
      @title = "New #{@target} category"
      @tag_name = "Create"
      render 'new'
    end
  end
  
  def edit
    @category = Category.find(params[:id])
    @title = "Edit category"
    @tag_name = "Confirm changes"
    @targets = Category::TARGET_TYPES
  end
  
  def update
    
    @category = Category.find(params[:id])
    @auth1 = @category.authorized
    @sent_before = @category.message_sent
    @original_name = @category.category
    @original_group = @category.target
    @user = User.find(@category.user_id)
    
    if @category.update_attributes(params[:category])
      
      #no need to send email if rejecting after authorization: -
      #if submitter hasn't associated programs with the category, it couldn't have been important.
      if @category.now_rejected_after_authorized(@auth1)
        @category.update_attribute(:message_sent, false)
      end
        
      flash[:success] = @category.success_message(@auth1, @sent_before, @original_name, @original_group)  
      redirect_to admin_categories_path(:id => @category.target)
    else
      @title = "Edit category"
      @targets = Category::TARGET_TYPES 
      @tag_name = "Confirm changes"
      render "edit"
    end  
  end
    
  
  def destroy
    @category = Category.find(params[:id])
    @category_name = @category.category
    @category.destroy
    flash[:success] = "#{@category_name} has been deleted."
    redirect_to admin_categories_path(:id => @category.target)
  end
end
