require 'spec_helper'

describe Resource do
  
  before(:each) do
    @name = "Abc"
    @small_name = "abc"
    @region = Factory(:region)
    @country = Factory(:country, :region_id => @region.id)
    @user = Factory(:user, :country_id => @country.id)
    @category = Factory(:category, :user_id => @user.id)
    @category2 = Factory(:category, :category => "cat2", :user_id => @user.id)
    @vendor = Factory(:vendor, :country_id => @country.id)
    @vendor2 = Factory(:vendor, :name => "vendor2", :country_id => @country.id)
    @medium = Factory(:medium, :user_id => @user.id)
    @attr = { :name => @name, :vendor_id => @vendor.id, :category_id => @category.id, :medium_id => @medium.id }
  end
  
  it "should create an instance given valid attributes" do
    Resource.create!(@attr) 
  end
  
  it "should not accept an empty name field" do
    @no_name = Resource.new(@attr.merge(:name => ""))
    @no_name.should_not be_valid
  end
  
  it "should not accept a long name field" do
    @long = "a" * 51
    @long_name = Resource.new(@attr.merge(:name => @long))
    @long_name.should_not be_valid
  end
  
  it "should not accept a duplicate name for the same vendor and category" do
    Resource.create!(@attr)
    @duplicate = Resource.new(@attr.merge(:name => @name, :vendor_id => @vendor.id, :category_id => @category.id))
    @duplicate.should_not be_valid
  end
  
  it "should not accept a duplicate name up to case for the same vendor and category" do
    Resource.create!(@attr)
    @punc_duplicate = Resource.new(@attr.merge(:name => @small_name, :vendor_id => @vendor.id, 
                                               :category_id => @category.id))
    @punc_duplicate.should_not be_valid
  end
  
  it "should accept a duplicate name for the same vendor but in a different category" do
    Resource.create!(@attr)
    @ok_duplicate = Resource.new(@attr.merge(:name => @name, :vendor_id => @vendor.id, 
                                               :category_id => @category2.id))
    @ok_duplicate.should be_valid
  end
  
  it "should accept a duplicate name for a different vendor but in the same category" do
    Resource.create!(@attr)
    @another_vendor_dup = Resource.new(@attr.merge(:name => @name, :vendor_id => @vendor2.id, 
                                               :category_id => @category.id))
    @another_vendor_dup.should be_valid
  end
  
  it "should not accept a blank vendor_id" do
    @blank_vendor = Resource.new(@attr.merge(:vendor_id => nil ))
    @blank_vendor.should_not be_valid
  end
  
  it "should not accept a blank category_id" do
    @blank_cat = Resource.new(@attr.merge(:category_id => nil ))
    @blank_cat.should_not be_valid
  end
  
  it "should not accept a blank medium_id" do
    @blank_medium = Resource.new(@attr.merge(:medium_id => nil ))
    @blank_medium.should_not be_valid
  end
  
  it "should not accept a blank length_unit" do
    @no_lengthunit_vendor = Resource.new(@attr.merge(:length_unit => "" ))
    @no_lengthunit_vendor.should_not be_valid
  end
  
  it "should accept a length_unit from the model list" do
    @good_lengthunit_vendor = Resource.new(@attr.merge(:length_unit => "Session"))
    @good_lengthunit_vendor.should be_valid
  end
  
  it "should not accept a length_unit if it's not in the model list" do
    @wrong_lengthunit_vendor = Resource.new(@attr.merge(:length_unit => "Weekend"))
    @wrong_lengthunit_vendor.should_not be_valid
  end
  
  it "should not accept a blank length value" do
    @no_length = Resource.new(@attr.merge(:length => "" ))
    @no_length.should_not be_valid
  end
  
  it "should reject a non-number as the length attribute" do
    @incorrect_length = Resource.new(@attr.merge(:length => "Four" ))
    @incorrect_length.should_not be_valid
  end
  
  it "should reject a non-integer as the length attribute" do
    @non_integer_length = Resource.new(@attr.merge(:length => 3.75 ))
    @non_integer_length.should_not be_valid
  end
  
  it "should reject a long description" do
    @long_d = "a" * 256
    @long_description = Resource.new(@attr.merge(:description => @long_d))
    @long_description.should_not be_valid
  end
  
  it "should reject a long webpage" do
    @long_w = "a" * 51
    @long_webpage = Resource.new(@attr.merge(:webpage => @long_w))
    @long_webpage.should_not be_valid
  end
end
