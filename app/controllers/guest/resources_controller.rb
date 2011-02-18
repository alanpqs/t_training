class Guest::ResourcesController < ApplicationController
  
  def index
    @resources = Resource.publicly_listed.paginate(:page => params[:page], :per_page => 20)

    @title = "Find a training resource"
    @tag_name = "Search"
    
    @instructions = "The list shows available training resources, with the most recently-added at the top."
    @instructions_2 = "The green check-button indicates that you can place orders now - click on the 
                      resource Name for more details."
    @instructions_3 = "A ticket icon shows that there are discounted tickets now available - but you need
                      to be a signed-up member before you can get tickets."
    @instructions_4 = "'Rating' is a percentage figure based on member reviews.  A high rating indicates a
                      high member satisfaction level.  No rating will appear until there have been at least
                      3 reviews - and the vendor may also choose not to display the rating."
    @instructions_5 = "Enter a few keywords in the 'Search' box above to find the resources you want.
                     Click on the 'Effective searches' button for more guidance." 
  end

  def show
    @resource = Resource.find(params[:id])
    @title = @resource.name
    @vendor = Vendor.find(@resource.vendor_id)
    @scheduled_events = @resource.current_and_scheduled_events
    @item = Item.find_by_resource_id(@resource.id) unless @resource.schedulable?
  end

end
