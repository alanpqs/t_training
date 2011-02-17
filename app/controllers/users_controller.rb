class UsersController < ApplicationController
  
  before_filter :authenticate, :only => [:index, :edit, :update, :destroy]
  before_filter :correct_user, :only => [:edit, :update]
  before_filter :admin_user,   :only => [:index, :destroy]
  
  
  def index
    @title = "All users"
    @users = User.paginate(:page => params[:page])
  end
  
  def show
    @user = User.find(params[:id])
    @title = @user.name
  end
  
  def new
    @title = "Sign Up"
    @user = User.new
    @countries = Country.find(:all, :order => "name")
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      log_in @user
      flash[:success] = "Welcome to Tickets for Training!"
      if @user.vendor?
        redirect_to business_home_path
      elsif @user.admin?
        redirect_to admin_home_path
      else  
        #redirect_to @user
        redirect_to member_home_path
      end
    else
      @title = "Sign Up"
      @user.password = nil
      @user.password_confirmation = nil
      @countries = Country.find(:all, :order => "name")
      render 'new'
    end
  end
  
  def edit
    @title = "Edit user"
    @countries = Country.find(:all, :order => "name")
  end
  
  def update
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated."
      redirect_to @user
    else
      @title = "Edit user"
      @countries = Country.find(:all, :order => "name")
      render 'edit'
    end
  end
  
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User destroyed."
    redirect_to users_path
  end
  
  def forgotten_password
    @tag_name = "Send request"
  end
  
  def new_password
    @user = User.find_by_email(params[:user][:email])
    if @user.nil?
      flash[:error] = "We couldn't find the email address you entered in the T4T member database. Are 
        you sure this is the address you gave when you signed up?"
      @tag_name = "Send request"
      redirect_to forgotten_password_path
    else
      @pw = User.generated_password
      @user.update_attributes(:password => @pw, :password_confirmation => @pw)
      UserMailer.new_password(@user, @pw).deliver
      flash[:success] = "Your new password is being emailed to you now."
      redirect_to login_path
    end
  end
  
  private
    
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end
    
    
    
end
