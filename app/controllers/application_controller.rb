class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  
  before_filter :latest_issues
  
  
  private
    def latest_issues
      @latest_issues = Issue.find(:all, 
          :conditions => ["expiry_date >=? and subscribed =?", Date.today, false], 
          :order => "updated_at DESC", :limit => 3)
    end
  
end
