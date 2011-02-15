require 'spec_helper'

describe ApplicationController do
  
  render_views
  
  before(:each) do
    @region = Factory.create(:region)
    @country = Factory(:country, :name => "United Kingdom", :currency_code => "GBP", :region_id => @region.id)
    @fee = Factory(:fee, :band => "C", :bottom_of_range => 100.00, :top_of_range => 199.99, 
                         :credits_required => 3)
    @user = Factory(:user, :country_id => @country.id, :vendor => true)
    @vendor = Factory(:vendor, :country_id => @country.id, :verified => true)
    @representation = Factory(:representation, :user_id => @user, :vendor_id => @vendor)
    @medium = Factory(:medium, :user_id => @user.id, :scheduled => true)
    @category = Factory(:category, :user_id => @user.id, :authorized => true)
    @resource = Factory(:resource, :vendor_id => @vendor.id, :category_id => @category.id, 
                                   :medium_id => @medium.id)
    @resource2 = Factory(:resource, :name => "Not shown", :vendor_id => @vendor.id, 
                                    :category_id => @category.id, 
                                    :medium_id => @medium.id)                             
    @item1 = Factory(:item, :resource_id => @resource.id, :currency => "GBP")
    @item2 = Factory(:item, :resource_id => @resource2.id, :reference => "ABC1", :days => "Tue/Wed/Thu",
                            :time_of_day => "Evenings", :start => Time.now - 2.days,
                            :finish => Time.now + 10.days,
                            :currency => "GBP")
    
    @issue4 = Factory(:issue, :item_id => @item2.id, :vendor_id => @vendor.id, :fee_id => @fee.id,
                              :user_id => @user.id, :cents => 14000, :currency => "GBP",
                              :expiry_date => Time.now + 4.days) 
    # issue 4 is the earliest created of 4 - so not shown
                                                      
    @issue1 = Factory(:issue, :item_id => @item1.id, :vendor_id => @vendor.id, :fee_id => @fee.id,
                              :user_id => @user.id, :cents => 12000, :currency => "GBP")
    @issue2 = Factory(:issue, :item_id => @item1.id, :vendor_id => @vendor.id, :fee_id => @fee.id,
                              :user_id => @user.id, :cents => 11000, :currency => "GBP",
                              :expiry_date => Time.now + 4.days)
    @issue3 = Factory(:issue, :item_id => @item1.id, :vendor_id => @vendor.id, :fee_id => @fee.id,
                              :user_id => @user.id, :cents => 10100, :currency => "GBP",
                              :expiry_date => Time.now + 6.days)
     
                               
    @issues = [@issue1, @issue2, @issue3, @issue4]                                                  
  end
  
  describe "the right-hand display panel" do
    controller do
      def index
        render :partial => "layouts/right_panel"
      end
    end
    
    it "should display the latest ticket issues" do
      get :index
      response.should have_selector(".rounded_right", :content => @resource.name)
    end
    
    it "should only display the 3 most recent issues" do
      get :index
      response.should_not have_selector(".rounded_right", :content => @resource2.name)
    end
    
    it "should include the resource category" do
      get :index
      response.should have_selector(".rounded_right", :content => @resource.category.category)
    end
    
    it "should include the vendor name" do
      get :index
      response.should have_selector(".rounded_right", :content => @resource.vendor.name)
    end
    
    it "should include the vendor location" do
      get :index
      response.should have_selector(".rounded_right", :content => @resource.vendor.address)
    end
    
    it "should include the vendor country" do
      get :index
      response.should have_selector(".rounded_right", :content => @resource.vendor.country.name)
    end
    
    it "should include the offer discount" do
      discount_1 = (@item1.cents.to_f - @issue1.cents.to_f) / @item1.cents.to_f * 100
      formatted_discount = sprintf("%.2f", discount_1)
      get :index
      response.should have_selector(".rounded_right", :content => "#{formatted_discount}% DISCOUNT") 
    end
    
    it "should include the expiry date" do
      expiry = @issue1.expiry_date.strftime('%d-%b-%Y')
      get :index
      response.should have_selector(".rounded_right", :content => "#{expiry}")
    end
    
    it "should not include offers that have expired" do
      @issue_expired = Factory(:issue, :item_id => @item2.id, :vendor_id => @vendor.id, :fee_id => @fee.id,
                              :user_id => @user.id, :cents => 11000, :currency => "GBP",
                              :expiry_date => Time.now - 1.day)
      get :index
      response.should_not have_selector(".rounded_right", :content => "Not shown")                          
    end
    
    it "should not include offers that have been fully subscribed" do
      @issue_subscribed = Factory(:issue, :item_id => @item2.id, :vendor_id => @vendor.id, :fee_id => @fee.id,
                              :user_id => @user.id, :cents => 11000, :currency => "GBP",
                              :expiry_date => Time.now + 1.day, :subscribed => true)
      get :index
      response.should_not have_selector(".rounded_right", :content => "Not shown")   
    end
  end
end
