class Business::VendorsController < ApplicationController
  
  def index
  end

  def new
    @title = "New vendor"
    @vendor = Vendor.new
  end

end
