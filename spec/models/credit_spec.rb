require 'spec_helper'

describe Credit do
  
  before(:each) do
    @region = Factory(:region)
    @country = Factory(:country, :region_id => @region.id)
    @user = Factory(:user, :country_id => @country.id, :vendor => true)
    @vendor = Factory(:vendor, :country_id => @country.id, :verified => true)
    @representation = Factory(:representation, :user_id => @user.id, :vendor_id => @vendor.id)
    
    @attr = { :vendor_id => @vendor.id, :quantity => 50, :cents => 5000 }
  end
  
  it "should create a new instance given valid attributes" do
    Credit.create!(@attr) 
  end
  
  it "should not have a blank 'vendor_id'" do
    @blank_vendor = Credit.new(@attr.merge(:vendor_id => ""))
    @blank_vendor.should_not be_valid
  end
  
  it "should not have a blank 'currency' attribute" do
    @blank_currency = Credit.new(@attr.merge(:currency => ""))
    @blank_currency.should_not be_valid
  end
  
  it "should not have a long 'currency' attribute" do
    @blank_currency = "$" * 4
    @blank_currency_credit = Credit.new(@attr.merge(:currency => @blank_currency))
    @blank_currency_credit.should_not be_valid
  end
  
  it "should not have a blank 'cents' attribute" do
    @blank_cents = Credit.new(@attr.merge(:cents => nil))
    @blank_cents.should_not be_valid
  end
  
  it "should not have a blank 'quantity' attribute" do
    @blank_quantity = Credit.new(@attr.merge(:quantity => nil))
    @blank_quantity.should_not be_valid
  end
  
  it "should only accept an integer for 'quantity'" do
    @fraction_quantity = Credit.new(@attr.merge(:quantity => 1.5))
    @fraction_quantity.should_not be_valid
  end
  
  it "should not accept a long 'note'" do
    @long_note = "a" * 101
    @long_note_credit = Credit.new(@attr.merge(:note => @long_note))
    @long_note_credit.should_not be_valid
  end
  
  it "should accept duplicate vendor / quantity combinations" do
    Credit.create!(@attr)
    @duplicate_credit = Credit.new(@attr)
    @duplicate_credit.should be_valid
  end
  
  
end
