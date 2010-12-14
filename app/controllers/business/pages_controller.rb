class Business::PagesController < ApplicationController
  
  before_filter :authenticate#,    :except => [:create, :update]    
  #before_filter :legality_check,  :only   => [:create, :update]
  before_filter :vendor_user#,     :except => [:create, :update]   
  
  def home
    @user = current_user
    @title = "Training supplier - home"
    cookies[:vendor_id] = @user.get_single_company_vendor   #set to nil unless only one associated company    
  end

end
