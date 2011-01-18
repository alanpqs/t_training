class Events::ItemsController < ApplicationController
  def index
    @title = "Scheduled events"
    @vendor = current_vendor
    @events = Item.scheduled_events(@vendor.id)
  end

  def new
  end

  def show
  end

  def edit
  end

end
