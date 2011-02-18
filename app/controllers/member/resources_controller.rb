class Member::ResourcesController < ApplicationController
  
  def index
    @title = "All training - find a resource"
    @tag_name = "Search"
    
    if params[:search]
      query = params[:search]
      @search = Resource.search do
        keywords query
        with(:hidden, false)
        paginate :page => params[:page], :per_page => 20
      end
      @resources = @search.results
    else
      @resources = Resource.publicly_listed.paginate(:page => params[:page], :per_page => 20)
    end
      
    @instructions = "The list shows available training resources, with the most recently-added at the top."
    @instructions_2 = "The green check-button indicates that you can place orders now - click on the 
                      resource Name for more details."
    @instructions_3 = "A ticket icon shows that there are discounted tickets now available.
                      Again, click on the Name for more details."
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
