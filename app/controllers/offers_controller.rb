class OffersController < ApplicationController
  
  def show
    @issue = Issue.find(params[:id])
    @item = Item.find(@issue.item_id)
    @resource = Resource.find(@item.resource_id)
    @vendor = Vendor.find(@issue.vendor_id)
    @title = "Check details of new ticket issue"
    @savings = (@item.cents - @issue.cents) / @vendor.country.currency_multiplier
  end

end
