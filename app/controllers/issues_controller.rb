class IssuesController < ApplicationController
  
  def index
    @title = "Previous offers for this event"
    @item = Item.find(params[:item_id])
    @issues = @item.issues
    @vendor = Vendor.find(current_vendor)
    @resource = Resource.find(@item.resource_id)
  end
  
  
  def new
    @vendor = Vendor.find(current_vendor)
    @item = Item.find(params[:item_id])
    @issue = @item.issues.new
    @issue.vendor_id = @vendor.id
    @issue.event = @item.resource.medium.scheduled
    @issue.currency = @vendor.country.currency_code
    @issue.user_id = User.find(current_user).id
    @issue.fee_id = Fee.find(:first).id 
    if @item.start > Date.today
      @issue.expiry_date = @item.start - 1.day
    else
      @issue.expiry_date = Date.today + 1.day
    end
    @title = "Issue new tickets"
    @tag_name = "Create"
    @drop = "cancel"   
  end

  def create
    @item = Item.find(params[:item_id])
    @issue = @item.issues.new(params[:issue])
    @vendor = current_vendor
    @currency = @vendor.country.currency_code
    @multiplier = @vendor.country.currency_multiplier
    @price = params[:issue][:ticket_price]
    @cent_value = @price.to_d * @multiplier
    money = Money.new(@cent_value, @currency)
    @issue.cents = money.cents
    @issue.currency = money.currency.to_s
    @issue.fee_id = @issue.fee_band
    if @issue.save
      @fee = Fee.find_by_band(@issue.fee_band)
      @issue.update_attribute(:fee_id, @fee.id)
      if @issue.cents == 0
        flash[:notice] = "You've set the price to 0.00.  Are you sure that's correct?"
      else
        flash[:success] = "Check the details of your discounted tickets offer."
      end
      redirect_to issue_path(@issue)
    else
      @title = "Issue new tickets"
      @tag_name = "Create"
      @drop = "cancel" 
      render "new"
    end  
  end
  
  def show
    @issue = Issue.find(params[:id])
    @item = Item.find(@issue.item_id)
    @resource = Resource.find(@item.resource_id)
    @vendor = Vendor.find(@issue.vendor_id)
    @title = "Ticket issue"
    @fees = Fee.find(:all, :order => "bottom_of_range")
    @fee = @issue.fee_charged
  end
  
  def edit
    @issue = Issue.find(params[:id])
    @item = Item.find(@issue.item_id)
    @vendor = Vendor.find(@issue.vendor_id)
    @title = "Change ticket details"
    @tag_name = "Confirm changes"
    @drop = "drop changes"
  end
  
  def update
    @issue = Issue.find(params[:id]) 
    @vendor = current_vendor
    @currency = @vendor.country.currency_code
    @multiplier = @vendor.country.currency_multiplier
    @price = params[:issue][:ticket_price]
    @cent_value = @price.to_d * @multiplier
    money = Money.new(@cent_value, @currency)
    @issue.cents = money.cents
    @issue.currency = money.currency.to_s
    if @issue.update_attributes(params[:issue])
      @fee = Fee.find_by_band(@issue.fee_band)
      @issue.update_attribute(:fee_id, @fee.id)
      if @issue.cents == 0
        flash[:notice] = "You've set the price to 0.00.  Are you sure that's correct?"
      else
        flash[:success] = "The ticket details have been successfully updated."
      end
      redirect_to @issue
    else
      @title = "Change ticket details"
      @tag_name = "Confirm changes"
      @drop = "drop changes"
      render 'edit'
    end
  end
end
