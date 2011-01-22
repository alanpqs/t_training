class PastEventsController < ApplicationController
  
  
  def index
    @title = "Past events"
    @resource = Resource.find(current_resource)
    @vendor = Vendor.find(current_vendor)
    @items = @resource.past_events.paginate(:page => params[:page])
  end

end
