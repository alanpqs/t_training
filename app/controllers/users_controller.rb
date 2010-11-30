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
      redirect_to @user
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
  
  private
    
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end
    
end
