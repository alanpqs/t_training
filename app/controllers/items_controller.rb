class ItemsController < ApplicationController
  def index
    @title = "Current & future events"
    @resource = current_resource
    @vendor = current_vendor
    #@items = Item.find_all_by_resource_id(@resource).paginate(:page => params[:page])
    @items = @resource.current_and_scheduled_events.paginate(:page => params[:page])
  end

  def new
    @title = "Schedule a new event"
    @resource = current_resource
    @vendor = current_vendor
    @tag_name = "Create event"
    @item = Item.new
    @weekdays = Item::WEEKDAY_TYPES
  end

  def create
    @resource = Resource.find(params[:resource_id])
    @item = @resource.items.new(params[:item])
    @vendor = current_vendor
    @currency = @vendor.country.currency_code
    @multiplier = @vendor.country.currency_multiplier
    @price = params[:item][:price]
    @cent_value = @price.to_d * @multiplier
    money = Money.new(@cent_value, @currency)
    @mon = params[:item][:day_mon]
    @tue = params[:item][:day_tue]
    @wed = params[:item][:day_wed]
    @thu = params[:item][:day_thu]
    @fri = params[:item][:day_fri]
    @sat = params[:item][:day_sat]
    @sun = params[:item][:day_sun]
    @item.build_days_array(@mon, @tue, @wed, @thu, @fri, @sat, @sun) 
    @item.cents = money.cents
    @item.currency = money.currency
    if @item.save
      if @item.cents == 0
        flash[:notice] = "You've set the price to 0.00.  Are you sure that's correct?  (If not, make
           sure you enter a numeric value for price.)"
      else
        flash[:success] = "The new event has been successfully created."
      end
      redirect_to @resource
    else
      @title = "Schedule a new event"
      @vendor = current_vendor 
      @media = Medium.all_authorized
      @tag_name = "Create event"
      @weekdays = Item::WEEKDAY_TYPES
      render "new"
    end  
  end
  
  def show
    @item = Item.find(params[:id])
    @resource = Resource.find(@item.resource_id)
    @vendor = current_vendor  
    @title = "#{@resource.name}"
  end
  
  def edit
    @item = Item.find(params[:id])
    @title = "Edit Event ##{@item.ref}"
    @tag_name = "Confirm changes"
    @item.split_days_array
    @resource = current_resource
    @vendor = current_vendor
    @weekdays = Item::WEEKDAY_TYPES  
  end
  
  def update
    @item = Item.find(params[:id]) 
    @vendor = current_vendor
    @currency = @vendor.country.currency_code
    @multiplier = @vendor.country.currency_multiplier
    @price = params[:item][:price]
    @cent_value = @price.to_d * @multiplier
    money = Money.new(@cent_value, @currency)
    @mon = params[:item][:day_mon]
    @tue = params[:item][:day_tue]
    @wed = params[:item][:day_wed]
    @thu = params[:item][:day_thu]
    @fri = params[:item][:day_fri]
    @sat = params[:item][:day_sat]
    @sun = params[:item][:day_sun]
    @item.build_days_array(@mon, @tue, @wed, @thu, @fri, @sat, @sun) 
    @item.cents = money.cents
    @item.currency = money.currency

    if @item.update_attributes(params[:item])
      flash[:success] = "The event details have been successfully updated."
      redirect_to @item
    else
      @tag_name = "Confirm changes"
      @title = "Edit Event ##{@item.ref}"
      @tag_name = "Confirm changes"
      @resource = current_resource
      @vendor = current_vendor
      @weekdays = Item::WEEKDAY_TYPES  
    end
     
  end
  
  def destroy
    @item = Item.find(params[:id])
    @resource = Resource.find(@item.resource_id)
    @item_date = @item.start
    @item.destroy
    flash[:success] = "Event #{@item.ref} deleted."
    redirect_to(resource_items_path(@resource))
  end
end
