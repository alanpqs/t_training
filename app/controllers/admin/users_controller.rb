class Admin::UsersController < ApplicationController
  
  before_filter :authenticate
  #before_filter :correct_user, :only => [:edit, :update]
  before_filter :admin_user
  
  def index
    @title = "All users"
    @users = User.paginate(:page => params[:page])
  end
  
  def show
    @user = User.find(params[:id])
    @title = @user.name
  end
  
  #def new
  #  @title = "Sign Up"
  #  @user = User.new
  #end
  
  #def create
  #  @user = User.new(params[:user])
  #  if @user.save
  #    log_in @user
  #    flash[:success] = "Welcome to Tickets for Training!"
  #    redirect_to @user
  #  else
  #    @title = "Sign Up"
  #    @user.password = nil
  #    @user.password_confirmation = n@user = User.find(params[:id])il
  #    render 'new'
  #  end
  #end
  
  def edit
    @title = "Edit user"
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated."
      redirect_to admin_user_path(@user)
    else
      @title = "Edit user"
      render 'edit'
    end
  end
  
  def destroy
    @user = User.find(params[:id])
    @user_name = @user.name
    if current_user?(@user)
      flash[:notice]= "You cannot delete your own record."
    else   
      @user.destroy
      flash[:success] = "#{@user_name} removed from database."
    end  
    redirect_to admin_users_path
  end
  
  #private
    
    #def correct_user
    #  @user = User.find(params[:id])
    #  redirect_to(root_path) unless current_user?(@user)
    #end
end
