require 'spec_helper'

describe Vendor do
  
  before(:each) do
    @region = Factory(:region)
    @country = Factory(:country, :region_id => @region.id)
    @attr = { :name => "Abc de", :country_id => @country.id, :address => "London", 
              :email => "vendor@example.com" }
  end
  
  it "should create an instance given valid attributes" do
    Vendor.create!(@attr) 
  end
  
  it "should award 50 ticket credits to a new vendor" do
    new_vendor = Vendor.create(@attr)
    new_vendor.ticket_credits.should == 50
  end
  
  it "should not accept an empty name field" do
    empty_name = Vendor.new(@attr.merge(:name => ""))
    empty_name.should_not be_valid
  end
  
  it "should not accept an empty country_id field" do
    empty_country_id = Vendor.new(@attr.merge(:country_id => nil))
    empty_country_id.should_not be_valid
  end
  
  it "should not accept an empty address field" do
    empty_address = Vendor.new(@attr.merge(:address => ""))
    empty_address.should_not be_valid
  end
  
  it "should not accept a long name field" do
    long_name = "Ab " * 17
    long_name_vendor = Vendor.new(@attr.merge(:name => long_name))
    long_name_vendor.should_not be_valid
  end
  
  it "should not accept a duplicate name field in the same country" do
    Vendor.create!(@attr)
    duplicate_vendor = Vendor.new(@attr.merge(:name => "Abc de", :country => @country.id))
    duplicate_vendor.should_not be_valid
  end
  
  it "should not accept a duplicate name field in the same country up to punctuation" do
    Vendor.create!(@attr)
    duplicate_vendor = Vendor.new(@attr.merge(:name => "Abc De", :country => @country.id))
    duplicate_vendor.should_not be_valid
  end
  
  it "should not accept a long address field" do
    long_address = "De " * 51
    long_address_vendor = Vendor.new(@attr.merge(:address => long_address))
    long_address_vendor.should_not be_valid
  end
  
  it "should accept a duplicate address field" do
    Vendor.create!(@attr)
    duplicate_address = Vendor.new(@attr.merge(:name => "Efg Hi", :address => "London", 
                                               :country => @country.id))
    duplicate_address.should be_valid
  end
  
  it "should accept a correctly formatted website field, unless blank" do
    sites = ["www.mysite.com", "http://www.mysite.org", "http://fierce-earth-31.heroku.com/admin_home"]
    sites.each do |site|
      good_site_vendor = Vendor.new(@attr.merge(:website => site))
      good_site_vendor.should be_valid
    end
  end
  
  it "should not accept an incorrectly formatted website field" do
    pending "not found good enough test object which does not accept poorly formatted urls"
  end
  
  it "should not have a long phone field" do
    long_phone = "a" * 21
    long_phone_vendor = Vendor.new(@attr.merge(:phone => long_phone))
    long_phone_vendor.should_not be_valid
  end
  
  it "should not have a long email field" do
    long_email = "#{'a' * 40}@example.com"
    long_email_vendor = Vendor.new(@attr.merge(:email => long_email))
    long_email_vendor.should_not be_valid
  end
  
  it "should not have a long website field" do
    long_website = "www.#{'a' * 46}.com"
    long_website_vendor = Vendor.new(@attr.merge(:website => long_website))
    long_website_vendor.should_not be_valid
  end
  
  it "should not accept an incorrectly-formatted email field" do
    incorrect_email = "example.com"
    incorrect_email_vendor = Vendor.new(@attr.merge(:email => incorrect_email))
    incorrect_email_vendor.should_not be_valid
  end
  
  it "should not have a long description" do
    long_description = "e" * 256
    long_description_vendor = Vendor.new(@attr.merge(:description => long_description))
    long_description_vendor.should_not be_valid
  end
  
  it "should only accept an integer in the ticket_credits field" do
    @bad_attr = { :name => "Abc de", :country_id => @country.id, :address => "London", 
              :email => "vendor@example.com", :ticket_credits => 3.75 }
    bad_ticket_credit_vendor = Vendor.create(@bad_attr)
    bad_ticket_credit_vendor.should_not be_valid
  end
  
end
