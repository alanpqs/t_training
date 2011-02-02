class Admin::FeesController < ApplicationController
  
  before_filter :authenticate,    :except => [:create, :update]
  before_filter :legality_check,  :only   => [:create, :update]
  before_filter :admin_user
  
  def index
    @title = "Ticket costs"
    @fees = Fee.find(:all, :order => "bottom_of_range")
  end

  def new
    @title = "Add a new fee-band"
    @fee = Fee.new
    @tag_name = "Create"
    @drop = "cancel"
  end
  
  def create
    @fee = Fee.new(params[:fee])
    #@cost = params[:fee][:cost]
    #@currency = "USD"
    #@cent_value = @cost.to_d * 100
    #money = Money.new(@cent_value, "USD")
    #@fee.cents = money.cents
    #@fee.currency = money.currency.to_s
    if @fee.save
      flash[:success] = "New band created."
      redirect_to admin_fees_path
    else
      @title = "Add a new fee-band"
      @tag_name = "Create"
      @drop = "cancel"
      render "new"
    end
  end

  def edit
    @title = "Change fees"
    @fee = Fee.find(params[:id])
    @tag_name = "Confirm changes"
    @drop = "drop changes"
  end
  
  def update
    @fee = Fee.find(params[:id])
    #@cost = params[:fee][:cost]
    #@currency = "USD"
    #@cent_value = @cost.to_d * 100
    #money = Money.new(@cent_value, @currency)
    #@fee.cents = money.cents
    #@fee.currency = money.currency.to_s
    if @fee.update_attributes(params[:fee])
      flash[:success] = "Band updated."
      redirect_to admin_fees_path
    else
      @title = "Change fees"
      @tag_name = "Confirm changes"
      @drop = "drop changes"
      render 'edit'
    end
  end
  
  def destroy
    @fee = Fee.find(params[:id])
    @name = @fee.band
    #if @fee.has_issues?
    #  flash[:error] = "Cannot delete band #{@name} - linked to ticket issues."
    #else
      @fee.destroy
      flash[:success] = "Band #{@name} deleted."
    #end
    redirect_to(admin_fees_path)
  end
end
