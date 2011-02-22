require 'spec_helper'

describe Searchlist do
  
  before(:each) do
    @region = Factory(:region)
    @country = Factory(:country, :region_id => @region.id)
    @user = Factory(:user, :country_id => @country.id)
    @category = Factory(:category, :user_id => @user.id)
    @attr = { :user_id => @user.id, :focus => "Job", :category_id => @category.id, 
                                    :topics => "HR Payroll", :country_id => @country.id } 
  end
  
  it "should create an instance given valid attributes" do
    Searchlist.create!(@attr)
  end
  
  it "should not accept a missing user_id" do
    missing_user = Searchlist.new(@attr.merge(:user_id => nil))
    missing_user.should_not be_valid
  end
  
  it "should not accept a missing 'focus'" do
    missing_focus = Searchlist.new(@attr.merge(:focus => ""))
    missing_focus.should_not be_valid
  end
  
  it "should not accept an illegal 'focus'" do
    illegal_focus = Searchlist.new(@attr.merge(:focus => "Training"))
    illegal_focus.should_not be_valid
  end
  
  it "should not accept a missing 'category_id'" do
    missing_category = Searchlist.new(@attr.merge(:category_id => nil))
    missing_category.should_not be_valid
  end
  
  it "should not accept a blank 'topics' field" do
    missing_topics = Searchlist.new(@attr.merge(:topics => ""))
    missing_topics.should_not be_valid
  end
  
  it "should not accept a 'topics' field with too many characters" do
    @long_list = "a" * 81
    long_topics = Searchlist.new(@attr.merge(:topics => @long_list))
    long_topics.should_not be_valid
  end
  
  it "should not accept a 'topics' field with too many words" do
    @wordy = "This is a topic with too many words in it now"
    wordy_topics = Searchlist.new(@attr.merge(:topics => @wordy))
    wordy_topics.should_not be_valid
  end
  
  it "should not accept punctuation in the 'topics' field" do
    @punctuated = "This, is, it"
    punctuated_topics = Searchlist.new(@attr.merge(:topics => @wordy))
    punctuated_topics.should_not be_valid
  end
  
  it "should accept a legal entry in the 'proximity' field" do
    ok_proximity = Searchlist.new(@attr.merge(:proximity => 4))
    ok_proximity.should be_valid
  end
  
  it "should not accept an illegal entry in the 'proximity' field" do
    illegal_proximity = Searchlist.new(@attr.merge(:proximity => 6))
    illegal_proximity.should_not be_valid
  end
  
  it "should not accept a non-integer entry in the 'proximity' field" do
    fraction_proximity = Searchlist.new(@attr.merge(:proximity => 4.5))
    fraction_proximity.should_not be_valid
  end
  
  it "should not accept an invalid country_id" do
    pending "till better test for associated"
  end
  
  it "should accept a blank country_id" do
    blank_country = Searchlist.new(@attr.merge(:country_id => nil))
    blank_country.should be_valid
  end
  
  it "should accept a valid region_id" do
    ok_region = Searchlist.new(@attr.merge(:region_id => @region.id))
    ok_region.should be_valid
  end
  
  it "should not accept an invalid region_id" do
    pending "till better test for associated"
  end
  
  it "should accept a valid medium_id" do
    @medium = Factory(:medium, :user_id => @user.id)
    ok_medium = Searchlist.new(@attr.merge(:medium_id => @medium.id))
    ok_medium.should be_valid
  end
  
  it "should not accept an invalid medium_id" do
    pending "till better test for associated"
  end
end
