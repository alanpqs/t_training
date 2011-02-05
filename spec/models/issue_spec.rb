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
    @scheduled_item = Factory(:item, :resource_id => @scheduled_resource.id)
    
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
  
  it "should not accept an empty 'vendor_id'" do
    blank_vendor = Issue.new(@attr_event.merge(:vendor_id => nil))
    blank_vendor.should_not be_valid
  end
  
  it "should not accept an empty 'item_id'" do
    blank_item = Issue.new(@attr_event.merge(:item_id => nil))
    blank_item.should_not be_valid
  end
  
  it "should not accept an empty 'fee_id'" do
    blank_fee = Issue.new(@attr_event.merge(:fee_id => ""))
    blank_fee.should_not be_valid 
  end
  
  it "should not accept an empty 'user_id'" do
    blank_user = Issue.new(@attr_event.merge(:user_id => ""))
    blank_user.should_not be_valid
  end
  
  it "should not accept an empty 'cents' attribute" do
    no_cents = Issue.new(@attr_event.merge(:cents => nil))
    no_cents.should_not be_valid
  end
  
  it "should accept a 0 value as a 'cents' attribute" do
    zero_cents = Issue.new(@attr_event.merge(:cents => 0))
    zero_cents.should be_valid
  end
  
  it "should not accept a blank 'currency'" do
    no_currency = Issue.new(@attr_event.merge(:currency => nil))
    no_currency.should_not be_valid
  end
  
  it "should not accept a long currency" do
    long_currency = Issue.new(@attr_event.merge(:currency => "ABCD"))
    long_currency.should_not be_valid
  end
  
  it "should not accept a blank attribute for the number of tickets" do
    blank_tickets = Issue.new(@attr_event.merge(:no_of_tickets => nil))
    blank_tickets.should_not be_valid
  end
  
  it "should not accept a fraction for 'number_of_tickets" do
    fraction_tickets = Issue.new(@attr_event.merge(:no_of_tickets => 3.5))
    fraction_tickets.should_not be_valid
  end
  
  it "should include a valid 'contact method'" do
    valid_contact = Issue.new(@attr_event.merge(:contact_method => "Email"))
    valid_contact.should be_valid
  end
  
  it "should not accept invalid contact methods" do
    invalid_contact = Issue.new(@attr_event.merge(:contact_method => "Snailmail"))
    invalid_contact.should_not be_valid
  end
  
  it "should not accept a blank expiry date" do
    blank_expiry = Issue.new(@attr_event.merge(:expiry_date => nil))
    blank_expiry.should_not be_valid
  end
  
  it "should not accept a blank for 'credits'" do
    blank_credits = Issue.new(@attr_event.merge(:credits => nil))
    blank_credits.should_not be_valid
  end
  
  it "should only accept a whole number for 'credits'" do
    fraction_credits = Issue.new(@attr_event.merge(:credits => 3.5))
    fraction_credits.should_not be_valid
  end
  
    
end
