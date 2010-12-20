require 'spec_helper'

describe "Pages" do
  
  before(:each) do
    @region = Factory(:region)
    @country = Factory(:country, :region_id => @region.id)
    @user = Factory(:user, :country_id => @country.id, :vendor => true)
    @vendor = Factory(:vendor, :country_id => @country.id)
    @vendor2 = Factory(:vendor, :name => "Vendor2", :country_id => @country.id)
    @representation = Factory(:representation, :user_id => @user.id, :vendor_id => @vendor2.id)
    integration_log_in(@user)
    test_vendor_cookie(@user)
  end
  
  describe "resource_group page" do
     
    it "should redirect to the new vendor resource page for the vendor" do
      visit resource_group_path
      choose "group_Fun"
      click_button
      response.should be_success
      response.should have_selector("title", :content => "New resource")
    end
    
    it "should redisplay the resource_group page if no group was selected" do
      visit resource_group_path
      click_button
      response.should have_selector("title", :content => "New resource - select a group")
    end
      
  end
  
end
