require 'spec_helper'

describe Medium do
  
  before(:each) do
    @region = Factory(:region)
    @country = Factory(:country, :region_id => @region.id)
    @user = Factory(:user, :country_id => @country.id) 
    @attr = { :medium => "Abc", :user_id => @user.id}
  end
  
  it "should create a new medium given valid attributes" do
    Medium.create!(@attr)
  end
  
  it "should not accept an empty 'medium' attribute" do
    no_medium = Medium.new(@attr.merge(:medium => ""))
    no_medium.should_not be_valid
  end
  
  it "should not accept an empty 'self_id' attribute" do
    no_user = Medium.new(@attr.merge(:user_id => nil))
    no_user.should_not be_valid
  end
  
  it "should not accept a duplicate medium" do
    Medium.create!(@attr)
    duplicate_medium = Medium.new(@attr.merge(:medium => "Abc"))
    duplicate_medium.should_not be_valid
  end
  
  it "should not accept a duplicate medium up to case" do
    Medium.create!(@attr)
    duplicate_punct_medium = Medium.new(@attr.merge(:medium => "ABC"))
    duplicate_punct_medium.should_not be_valid
  end
  
  it "should not accept a long medium" do
    long_name = "a" * 31
    long_name_medium = Medium.new(@attr.merge(:medium => long_name))
    long_name_medium.should_not be_valid
  end
  
  it "should not accept a rejection_message for an authorized medium" do
    msg = "rejected"
    inappropriate_message = Medium.new(@attr.merge(:authorized => true, :rejection_message => msg))
    inappropriate_message.should_not be_valid
  end
  
end
