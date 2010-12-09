class Business::PagesController < ApplicationController
  
  before_filter :authenticate#,    :except => [:create, :update]    
  #before_filter :legality_check,  :only   => [:create, :update]
  before_filter :vendor_user#,     :except => [:create, :update]   
  
  def home
    @title = "Training supplier - home"
    @user = current_user
  end

end
