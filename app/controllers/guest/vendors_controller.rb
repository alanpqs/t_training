class Guest::VendorsController < ApplicationController
  
  def show
    @vendor = Vendor.find(params[:id])
    @title = @vendor.name
    @resources = @vendor.resources.all_current_by_vendor(@vendor).paginate(:per_page => 30, :page => params[:page])
  end

end
