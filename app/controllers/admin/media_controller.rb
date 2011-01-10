class Admin::MediaController < ApplicationController
  
  before_filter :authenticate,    :except => [:create, :update]
  before_filter :legality_check,  :only   => [:create, :update]
  before_filter :admin_user
  
  def index
    @title = "Training formats"
    @media = Medium.all(:order => "medium")
  end

  def new
    @title = "New training format"
    @tag_name = "Create"
    @medium = Medium.new
    @medium.user_id = current_user.id
  end

  def create
    @medium = Medium.new(params[:medium])
    if @medium.save
      flash[:success] = "'#{@medium.medium}' successfully created"
      redirect_to admin_media_path
    else
      @title = "New training format"
      @tag_name = "Create"
      render "new"
    end
  end
  
  def edit
    @medium = Medium.find(params[:id])
    @tag_name = "Confirm change"
    @title = "Modify training format"
  end

  def update
    @medium = Medium.find(params[:id])
    if @medium.update_attributes(params[:medium])
      flash[:success] = "'#{@medium.medium}' has been successfully changed."
      redirect_to admin_media_path
    else
      @tag_name = "Confirm change"
      @title = "Modify training format"
      render 'edit'
    end
  end
  
  def destroy
    @medium = Medium.find(params[:id])
    @name = @medium.medium
    if @medium.destroy
      flash[:success] = "'#{@name}' deleted"
    else
      flash[:error] = "'#{@name}' cannot be deleted.  (You can only delete rejected formats)."
    end
    redirect_to admin_media_path
  end
  
end
