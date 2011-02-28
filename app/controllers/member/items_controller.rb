class Member::ItemsController < ApplicationController
  
  def show
    @item = Item.find(params[:id])
    @resource = Resource.find(@item.resource_id)
    @vendor = Vendor.find(@resource.vendor_id)  
    @title = "#{@resource.name}"
  end

end
