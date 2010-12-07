require 'spec_helper'

describe Representation do
  
  before(:each) do
    @region = Factory(:region)
    @country = Factory(:country, :region_id => @region.id)
    @user = Factory(:user, :country_id => @country.id)
    @vendor = Factory(:vendor, :country_id => @country.id)
    @attr = { :user_id => @user.id, :vendor_id => @vendor.id}
  end
  
  it "should create an instance given valid attributes" do
    Representation.create!(@attr) 
  end
  
  it "should not succeed with a missing user" do
    missing_user = Representation.new(@attr.merge(:user_id => nil))
    missing_user.should_not be_valid
  end
  
  it "should not succeed with a missing vendor" do
    missing_vendor = Representation.new(@attr.merge(:vendor_id => nil))
    missing_vendor.should_not be_valid
  end
  
  it "should not be accepted with a duplicate user/vendor combination" do
    Representation.create!(@attr)
    duplicate_record = Representation.new(@attr.merge(:vendor_id => @vendor.id, :user_id => @user.id))
    duplicate_record.should_not be_valid
  end
  
end
