class Business::MediaController < ApplicationController
  
  before_filter :check_login,             :only => :new           
  before_filter :vendor_user,             :only => :new
  before_filter :vendor_legality_check,   :only =>  :create 
  
  def new
    @title = "Suggest a new format"
    @medium = Medium.new
    @medium.user_id = current_user.id
    @tag_name = "Send your suggestion"
    @media = Medium.find(:all, :order => "medium")
  end
  
  def create
    @medium = Medium.new(params[:medium])
    if @medium.save
      flash[:success] = "You've proposed a new format - '#{@medium.medium}'.  We'll respond soon by email."
      redirect_to session[:return_to]
    else
      @title = "Suggest a new format"
      @tag_name = "Send your suggestion"
      @medium.user_id = current_user.id
      @media = Medium.find(:all, :order => "medium")
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
