class Admin::CategoryApprovalsController < ApplicationController
  
  before_filter :authenticate,    :except => [:create, :update]    
  before_filter :legality_check,  :only   => [:create, :update]
  before_filter :admin_user,      :except => [:create, :update]      
  
  
  def index
    @title = "Unauthorized training categories" 
    @categories = Category.all_approvals_needed
    @other_groups = Category::TARGET_TYPES
  end

  #def new
  #  @target = params[:id]
  #  @title = "New #{@target} category"
  #  @category = Category.new(:target => @target, :user_id => current_user.id)
  #  @tag_name = "Create"
  #end
  
  #def create
  #  @category = Category.new(params[:category])
  #  @content = @category.category
  #  @target = @category.target
  #  @category.submitted_name = @content
  #  @category.submitted_group = @target
  #  if @category.save
  #    flash[:success] = "Thank you for adding '#{@content}' to #{@target}.  Your category submission 
  #      will now be checked and authorized, then added to the public list."
  #    redirect_to admin_category_approvals_path(:id => @target)
  #  else
  #    @title = "New #{@target} category"
  #    @tag_name = "Create"
  #    render 'new'
  #  end
  #end
  
  def edit
    @category = Category.find(params[:id])
    @title = "Category authorization"
    @tag_name = "Confirm changes"
    @targets = Category::TARGET_TYPES
    @member = User.find(@category.user_id) 
  end
  
  def update
    
    @category = Category.find(params[:id])
    
    @auth1 = @category.authorized               #sets up variables for flash messages
    @sent_before = @category.message_sent
    @original_name = @category.category
    @original_group = @category.target
    @user = User.find(@category.user_id)
    
    if @category.update_attributes(params[:category])
    
      if @category.authorized?
        if @category.now_authorized_after_rejection?
          
          #changes made
          if @category.should_mail_auth_mess_after_rej?(@category.submitted_name, @category.submitted_group)
            UserMailer.category_now_accepted_with_changes(@user, @category).deliver
            @category.update_attributes(:message_sent => true, :message => nil)
          else
          #no changes made
            UserMailer.category_now_accepted(@user, @category).deliver
            @category.update_attributes(:message_sent => true, :message => nil)
          end      
        else
          
          #authorization with changes
          if @category.should_mail_authorization_message?(@category.submitted_name, @category.submitted_group)
            UserMailer.category_authorized_with_changes(@user, @category).deliver
            @category.update_attributes(:message_sent => true, :message => nil)
          end
          #if simply authorized with no changes, only add to the authorized list - no email
        
        end
      else
        #rejections
        if @category.should_mail_submission_message?  
          UserMailer.category_not_authorized(@user, @category).deliver
          @category.update_attribute(:message_sent, true)      
        end  
      end
        
      flash[:success] = @category.success_message(@auth1, @sent_before, @original_name, @original_group)  
      redirect_to admin_category_approvals_path
    else
      @title = "Category authorization"
      @targets = Category::TARGET_TYPES 
      @tag_name = "Confirm changes"
      @member = User.find(@category.user_id) 
      render "edit"
    end  
  end
    
  
  def destroy
    @category = Category.find(params[:id])
    @category_name = @category.category
    @category.destroy
    flash[:success] = "#{@category_name} has been deleted."
    redirect_to admin_category_approvals_path
  end

end
