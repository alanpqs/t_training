class UnscheduledItemsController < ApplicationController
  
  def new
    @title = "Add pricing / availability details"
    @resource = current_resource
    @vendor = current_vendor
    @item = Item.new
    @tag_name = "Confirm entry"
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
    @item.cents = money.cents
    @item.currency = money.currency
    if @item.save
      if @item.cents == 0
        flash[:notice] = "You've set the price to 0.00.  Are you sure that's correct?  (If not, make
           sure you enter a numeric value for price.)"
      else
        flash[:success] = "Availability and pricing details have been successfully added."
      end
      redirect_to @resource
    else
      @title = "Add pricing / availability details"
      @tag_name = "Confirm entry"
      render 'new'
    end  
  end
  
  def edit
    @item = Item.find(params[:id])
    @title = "Edit availability and pricing"
    @tag_name = "Confirm changes"
    @resource = current_resource
    @vendor = current_vendor
  end
  
  def update
    @item = Item.find(params[:id]) 
    @vendor = current_vendor
    @resource = current_resource
    @currency = @vendor.country.currency_code
    @multiplier = @vendor.country.currency_multiplier
    @price = params[:item][:price]
    @cent_value = @price.to_d * @multiplier
    money = Money.new(@cent_value, @currency)
    @item.cents = money.cents
    @item.currency = money.currency

    if @item.update_attributes(params[:item])
      if @item.cents == 0
        flash[:notice] = "You've set the price to 0.00.  Are you sure that's correct?  (If not, make
           sure you enter a numeric value for price.)"
      else
        flash[:success] = "Price and availability details have been successfully updated."
      end
      redirect_to resource_path(@resource)
    else
      @tag_name = "Confirm changes"
      @title = "Edit availability and pricing"
      @tag_name = "Confirm changes"
      render "edit"
    end
  end

end
