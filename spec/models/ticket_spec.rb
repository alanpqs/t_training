require 'spec_helper'

describe Ticket do
  
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
    @scheduled_item = Factory(:item, :resource_id => @scheduled_resource.id)
    @scheduled_issue = Factory(:issue, :vendor_id => @vendor.id, :item_id => @scheduled_item.id, 
                              :fee_id => @fee.id, :user_id => @user.id)
    @unscheduled_issue = Factory(:issue, :vendor_id => @vendor.id, :item_id => @unscheduled_item.id, 
                              :fee_id => @fee.id, :user_id => @user.id)                          
    @customer = Factory(:user, :name => "Customer", :email => "customer@example.com", 
                        :country_id => @country.id)
    
    @attr_event = { :issue_id => @scheduled_issue.id, :user_id => @customer.id, :credits => 1 }
    @attr_resource = { :issue_id => @unscheduled_issue.id, :user_id => @customer.id, :credits => 1 }
  end
  
  it "should create a new instance for a scheduled event given valid attributes" do
    Ticket.create!(@attr_event) 
  end
  
  it "should create a new instance for a non-scheduled resource given valid attributes" do
    Ticket.create!(@attr_resource) 
  end
  
  it "should not accept a blank 'user_id'" do
    @blank_user = Ticket.new(@attr_event.merge(:user_id => ""))
    @blank_user.should_not be_valid
  end
  
  it "should not accept a blank 'issue_id'" do
    @blank_issue = Ticket.new(@attr_event.merge(:user_id => nil))
    @blank_issue.should_not be_valid
  end
  
  it "should not accept a blank 'quantity'" do
    @blank_qty = Ticket.new(@attr_event.merge(:quantity => nil))
    @blank_qty.should_not be_valid
  end
  
  it "should accept a zero value for 'quantity'" do
    @zero_qty = Ticket.new(@attr_event.merge(:quantity => 0))
    @zero_qty.should be_valid
  end
  
  it "should accept a negative value for 'quantity'" do
    @negative_qty = Ticket.new(@attr_event.merge(:quantity => -1))
    @negative_qty.should be_valid
  end
  
  it "should only accept an integer for 'quantity'" do
    @fraction_qty = Ticket.new(@attr_event.merge(:quantity => 1.5))
    @fraction_qty.should_not be_valid
  end
  
  it "should not accept a blank 'credits' attribute" do
    @blank_credits = Ticket.new(@attr_event.merge(:credits => nil))
    @blank_credits.should_not be_valid
  end
  
  it "should accept a zero value for 'credits'" do
    @zero_credits = Ticket.new(@attr_event.merge(:credits => 0))
    @zero_credits.should be_valid
  end
  
  it "should only accept an integer for 'credits'" do
    @fraction_credits = Ticket.new(@attr_event.merge(:credits => 1.5))
    @fraction_credits.should_not be_valid
  end
  
end
