class Guest::ResourcesController < ApplicationController
  def index
    @resources = Resource.publicly_listed.paginate(:page => params[:page], :per_page => 20)

    @title = "Find a training resource"
    @tag_name = "Search"
  end

  def show
    @resource = Resource.find(params[:id])
    @title = @resource.name
    @vendor = Vendor.find(@resource.vendor_id)
    @scheduled_events = @resource.current_and_scheduled_events
    @item = Item.find_by_resource_id(@resource.id) unless @resource.schedulable?
  end

end
