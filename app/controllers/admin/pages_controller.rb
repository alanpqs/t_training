class Admin::PagesController < ApplicationController
  
  before_filter :authenticate
  before_filter :admin_user
  
  def home
    @title = "Admin home-page"
  end

end
