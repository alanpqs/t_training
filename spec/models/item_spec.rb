require 'spec_helper'

describe Item do
  
  before(:each) do
    @region = Factory(:region)
    @country = Factory(:country, :region_id => @region.id)
    @user = Factory(:user, :country_id => @country.id)
    @vendor = Factory(:vendor, :country_id => @country.id)
    @category = Factory(:category, :user_id => @user.id)
    @unscheduled_medium = Factory(:medium, :user_id => @user.id)
    @scheduled_medium = Factory(:medium, :medium => "Efg", :user_id => @user.id, :scheduled => true)
    @unscheduled_resource = Factory(:resource, :vendor_id => @vendor.id, :category_id => @category.id,
                                   :medium_id => @unscheduled_medium.id)
    @scheduled_resource = Factory(:resource, :name => "Scheduled", :vendor_id => @vendor.id, 
                                             :category_id => @category.id,
                                             :medium_id => @scheduled_medium.id)        
    @attr_event = { :resource_id => @scheduled_resource.id, :start => "2011-02-13",
                                                  :end => "2011-03-13", :days => "Mon/Wed/Fri",
                                                  :time_of_day => "Evenings", :cents => 24500,
                                                  :currency => "USD", :venue => "Our premises" }
    @attr_ongoing = { :resource_id => @unscheduled_resource.id, :start => "2010-08-13", :cents => 20000,
                                                  :currency => "USD", :venue => "Directly from us"  }
  end
  
  
  it "should create an 'event' instance given valid attributes" do
    Item.create!(@attr_event) 
  end
  
  it "should create a 'permanent resource' instance given valid attributes" do
    Item.create!(@attr_ongoing)
  end
  
  it "should not accept an empty 'resource_id' field" do
    @no_name = Item.new(@attr_ongoing.merge(:resource_id => ""))
    @no_name.should_not be_valid
  end
  
  it "should not accept a blank start-date" do
    @no_start_date = Item.new(@attr_event.merge(:start => ""))
    @no_start_date.should_not be_valid
  end
    
  it "should not accept a duplicate start-date for the same resource in the same venue" do
    Item.create!(@attr_event)
    @duplicate_start = Item.new(@attr_event.merge(:reference => "B21")) 
    @duplicate_start.should_not be_valid
  end
  
  it "should accept a duplicate start-date for the same resource but with a different venue" do
    Item.create!(@attr_event)
    @duplicate_ok = Item.new(@attr_event.merge(:reference => "B21", :venue => "Training center")) 
    @duplicate_ok.should be_valid
  end
  
  it "should not accept a blank end-date for an event" do
    @no_end_date = Item.new(@attr_event.merge(:end => ""))
    @no_end_date.should_not be_valid
  end
  
  it "should accept a blank end-date for a permanent resource" do
    @no_end_date = Item.new(@attr_ongoing.merge(:end => ""))
    @no_end_date.should be_valid
  end
  
  it "should accept an empty field for 'days'" do
    @no_days = Item.new(@attr_event.merge(:days => ""))
    @no_days.should be_valid
  end
  
  it "should not accept a long field for 'days'" do
    @long = "Sat/Sun/Mon/Tue/Wed/Thu/Fri/Lun"
    @long_name = Item.new(@attr_event.merge(:days => @long))
    @long_name.should_not be_valid
  end
   
  it "should accept values from DAYTIME_TYPES as time_of_day attributes" do
    @good_value = "Evenings"
    @daytime_correct = Item.new(@attr_event.merge(:time_of_day => @good_value))
    @daytime_correct.should be_valid
  end
  
  it "should not accept attributes not listed in DAYTIME_TYPES in the time_of_day column" do
    @bad_value = "Daybreak"
    @daytime_wrong = Item.new(@attr_event.merge(:time_of_day => @bad_value))
    @daytime_wrong.should_not be_valid
  end
  
  it "should accept a blank entry in the time_of_day column" do
    @no_value = ""
    @daytime_blank = Item.new(@attr_event.merge(:time_of_day => @no_value))
    @daytime_blank.should be_valid
  end
  
  it "should not accept an empty 'cents' attribute" do
    @price_blank = Item.new(@attr_event.merge(:cents => ""))
    @price_blank.should_not be_valid
  end
  
  it "should not accept a nil 'cents' attribute" do
    @price_nil = Item.new(@attr_event.merge(:cents => nil))
    @price_nil.should_not be_valid
  end
  
  it "should not accept a nil 'currency' attribute" do
    @currency_nil = Item.new(@attr_event.merge(:currency => nil))
    @currency_nil.should_not be_valid
  end
  
  it "should not accept a blank 'currency' attribute" do
    @currency_blank = Item.new(@attr_event.merge(:currency => ""))
    @currency_blank.should_not be_valid
  end
  
  it "should not accept a long 'currency' attribute" do
    @currency_long = Item.new(@attr_event.merge(:currency => "USD2"))
    @currency_long.should_not be_valid
  end
  
  it "should not accept decimal fractions for the 'cents' attribute" do
    @price_fraction = Item.new(@attr_event.merge(:cents => 2.75))
    @price_fraction.should_not be_valid
  end
  
  it "should accept an integer for 'cents'" do
    @price_ok = Item.new(@attr_event.merge(:cents => 1000000))
    @price_ok.should be_valid
  end
  
  it "should not accept an empty 'venue' attribute" do
    @no_venue = Item.new(@attr_event.merge(:venue => ""))
    @no_venue.should_not be_valid
  end
  
  it "should not accept a long 'venue' attribute" do
    @long = "a" * 101
    @long_venue = Item.new(@attr_event.merge(:venue => @long))
    @long_venue.should_not be_valid
  end 
end
