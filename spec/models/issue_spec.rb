require 'spec_helper'

describe Issue do
  
  before(:each) do
    @region = Factory(:region)
    @country = Factory(:country, :region_id => @region.id)
    @fee = Factory(:fee)
    @user = Factory(:user, :country_id => @country.id, :vendor => true)
    @vendor = Factory(:vendor, :country_id => @country.id, :verified => true)
    @representation = Factory(:representation, :user_id => @user.id, :vendor_id => @vendor.id) 
    @category = Factory(:category, :user_id => @user.id)
    @unscheduled_medium = Factory(:medium, :user_id => @user.id)
    @scheduled_medium = Factory(:medium, :medium => "Efg", :user_id => @user.id, :scheduled => true)
    @unscheduled_resource = Factory(:resource, :vendor_id => @vendor.id, :category_id => @category.id,
                                   :medium_id => @unscheduled_medium.id)
    @scheduled_resource = Factory(:resource, :name => "Scheduled", :vendor_id => @vendor.id, 
                                             :category_id => @category.id,
                                             :medium_id => @scheduled_medium.id)
    @unscheduled_item = Factory(:item, :resource_id => @unscheduled_resource.id, :start => "2011-01-01",
                                       :finish => nil)
    @scheduled_item = Factory(:item, :resource_id => @scheduled_resource)
    
    @attr_event = { :item_id => @scheduled_item.id, :vendor_id => @vendor.id, :event => true,
                    :cents => 14000, :currency => "USD", :fee_id => @fee.id, 
                    :expiry_date => Date.today + 7.days, :user_id => @user.id }
    @attr_ongoing = { :item_id => @unscheduled_item.id, :vendor_id => @vendor.id, :event => false,
                    :cents => 14000, :currency => "USD", :fee_id => @fee.id,
                    :expiry_date => Date.today + 7.days, :user_id => @user.id }
  end 
  
  it "should create an 'event' instance given valid attributes" do
    Issue.create!(@attr_event) 
  end
  
  it "should create a 'permanent resource' instance given valid attributes" do
    Issue.create!(@attr_ongoing)
  end
end
