require 'spec_helper'

describe Category do
  
  before(:each) do
    @attr = { :category => "Oil Gas and Energy", :aim => 0, :authorized => 0 }
  end
    
  it "should create an instance given valid attributes" do
    Category.create!(@attr) 
  end
   
  it "should not accept an empty 'category' field" do
    empty_category = Category.new(@attr.merge(:category => "")) 
    empty_category.should_not be_valid
  end
   
  it "should not accept a 'category' field longer than 30 characters" do
    long_name = "a" * 31
    long_category = Category.new(@attr.merge(:category => long_name))
    long_category.should_not be_valid
  end
   
  it "should not accept a duplicate 'category' field" do
    Category.create!(@attr)
    duplicate_category = Category.new(@attr.merge(:aim => 1))
    duplicate_category.should_not be_valid 
  end
   
  it "should not accept a duplicate 'category' field up to case" do
    new_title = "Oil gas and energy"
    Category.create!(@attr)
    dup_tocase_category = Category.new(@attr.merge(:category => new_title))
    dup_tocase_category.should_not be_valid  
  end
   
  it "should not accept a duplicate 'category' field up to punctuation" do
    new_title = "Oil Gas and Energy"
    Category.create!(@attr)
    dup_topunct_category = Category.new(@attr.merge(:category => new_title))
    dup_topunct_category.should_not be_valid   
  end
   
  it "should only accept an integer in the range 0-4 in the 'aim' field" do
    incorrect_aim_cat = Category.new(@attr.merge(:aim => 5))
    incorrect_aim_cat.should_not be_valid
  end
     
  it "should not accept an empty 'aim' field" do
    empty_aim_cat =  Category.new(@attr.merge(:aim => nil))
    empty_aim_cat.should_not be_valid
  end
end
