require 'spec_helper'

describe Region do
  
  before(:each) do
    @attr = { :region => "Europe"}
  end
  
  it "should create a new region given valid attributes" do
    Region.create!(@attr)
  end
  
  it "should not accept a blank entry" do
    no_region_entered = Region.new(@attr.merge(:region => ""))
    no_region_entered.should_not be_valid
  end
  
  it "should not accept a region entry longer than 25 characters" do
    long_name = "a" * 26
    long_region = Region.new(@attr.merge(:region => long_name))
    long_region.should_not be_valid
  end
  
  it "should not allow a duplicate region" do
    Region.create!(@attr)
    duplicate_region = Region.new(@attr)
    duplicate_region.should_not be_valid
  end
  
  it "should not allow a duplicate region if only the case is different" do
    upcased_region = @attr[:region].upcase
    Region.create!(@attr.merge(:region => upcased_region))
    duplicate_region = Region.new(@attr)
    duplicate_region.should_not be_valid
  end
  
end
