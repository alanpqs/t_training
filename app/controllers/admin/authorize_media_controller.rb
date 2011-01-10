class Admin::AuthorizeMediaController < ApplicationController
  
  before_filter :authenticate,    :except => :update
  before_filter :legality_check,  :only   => :update
  before_filter :admin_user
  
  def edit
    @medium = Medium.find(params[:id])
    @tag_name = "Confirm changes"
    @title = "Authorize training format"
  end

  def update
    @medium = Medium.find(params[:id])
    @medium_name = @medium.medium
    @authorization_status = @medium.authorized
    @user = User.find(@medium.user_id)
    if @medium.update_attributes(params[:medium])
      if @medium.rejected?
        UserMailer.medium_rejected(@user, @medium).deliver
        flash[:success] = "'#{@medium.medium}' has been rejected and an explanatory email sent."
      elsif @medium.authorized_with_changes?(@authorization_status, @medium_name, @medium.medium)
        UserMailer.medium_accepted_with_changes(@user, @medium_name, @medium.medium).deliver
        flash[:success] = "'#{@medium.medium}' has been authorized after changes - a notification has been emailed 
            to the submitter."
      elsif @medium.unauthorized?
        flash[:notice] = "Changes to '#{@medium.medium}' have been made, but it remains unauthorized."
      else
        flash[:success] = "'#{@medium.medium}' has been authorized - there were no changes so no email has been sent."
      end
      redirect_to admin_media_path
    else
      @tag_name = "Confirm changes"
      @title = "Authorize training format"
      render 'edit'
    end
  end
  
end
