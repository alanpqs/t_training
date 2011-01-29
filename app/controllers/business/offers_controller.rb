class Business::OffersController < ApplicationController
  
  def index
    @title = "All current offers"
    @vendor = Vendor.find(current_vendor)
    @issues = @vendor.issues.find(:all, :conditions => ["issues.expiry_date >=?", Date.today])
  end

end
