require 'spec_helper'

describe Category do
  
  before(:each) do
    @region = Factory(:region)
    @country = Factory(:country, :region_id => @region.id)
    @user = Factory(:user, :country_id => @country.id) 
    @attr = { :category => "Oil Gas and Energy",  :target => "Business", 
                                                  :authorized => 0,
                                                  :submitted_name => "Oil Gas and Energy",
                                                  :submitted_group => "Business", 
                                                  :user_id => @user.id
                                                  }
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
   
  it "should not accept a duplicate 'category' in the same group" do
    Category.create!(@attr)
    duplicate_category = Category.new(@attr.merge(:submitted_name => "ABC"))
    duplicate_category.should_not be_valid 
  end
  
  it "should accept a duplicate 'category' in a different group" do
    Category.create!(@attr)
    duplicate_category = Category.new(@attr.merge(:target => "Job"))
    duplicate_category.should be_valid 
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
   
  it "should accept a value from TARGET_TYPES in the 'target' field" do
    correct_target_cat = Category.new(@attr.merge(:target => "World" ))
    correct_target_cat.should be_valid
  end
  
  it "should not accept a value in the 'target' field if it is not included in TARGET_TYPES" do
    incorrect_target_cat = Category.new(@attr.merge(:target => "Local" ))
    incorrect_target_cat.should_not be_valid
  end
     
  it "should not accept an empty 'target' field" do
    empty_target_cat =  Category.new(@attr.merge(:target => ""))
    empty_target_cat.should_not be_valid
  end
  
  it "should not accept an empty 'user_id' field" do
    empty_user = Category.new(@attr.merge(:user_id => nil))
    empty_user.should_not be_valid
  end
  
  it "should automatically form the correct 'submitted_name' field on record creation" do
    empty_submitted_name = Category.create(@attr.merge(:category => "Submitted", :submitted_name => "")) 
    @new_category = Category.find(:last)
    @new_category.submitted_name.should == "Submitted"
  end
  
  it "should automatically form the correct 'submitted_group' field on record creation" do
    empty_submitted_group = Category.create(@attr.merge(:target => "World", :submitted_group => "")) 
    @new_category = Category.find(:last)
    @new_category.submitted_group.should == "World"
  end
end
