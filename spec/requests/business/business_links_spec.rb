require 'spec_helper'

describe "BusinessLinks" do
  
  before(:each) do
    @region = Factory(:region)
    @country = Factory(:country, :region_id => @region.id)
    @user = Factory(:user, :vendor => true, :country_id => @country.id)
    @vendor = Factory(:vendor, :country_id => @country.id, :verified => true)
    @representation = Factory(:representation, :user_id => @user.id, :vendor_id => @vendor.id)
    #integration_log_in(@user)
  end
  
  describe "in all circumstances" do
    
    before(:each) do
      integration_log_in(@user)
    end
        
    it "should redirect to the 'business/home' page" do
      visit business_home_path
      click_link "Home"
      response.should have_selector('title', :content => "Training supplier - home")
    end
  
    it "should have a new vendors link" do
      visit business_home_path
      response.should have_selector("a",  :href => new_business_vendor_path,
                                          :content => "Add a new vendor")  
    end
  end
  
  describe "when 'vendor_id' cookie is set and the vendor has been verified" do
    
    before(:each) do
      integration_log_in(@user)
    end
  
    it "should have the right links on the layout" do
      visit business_home_path
      click_link "Home"
      response.should have_selector('title', :content => "Training supplier - home")
      click_link "Vendor profile"
      response.should have_selector('title', :content => "#{@vendor.name}")
      click_link "Training resources"
      response.should have_selector('title', :content => "Resources")
      click_link "Add a new vendor"
      response.should have_selector('title', :content => "New vendor")
      click_link "Tickets"
      response.should have_selector('title', :content => "Tickets for Training") 
    end
    
    it "should have a supplier menu reference in the 'loginfo' div" do
      visit business_home_path
      response.should have_selector("div#loginfo", :content => "Menu:")
      response.should have_selector("div#loginfo", :content => @vendor.name)
    end
  end
  
  describe "when the vendor_id cookie is set but the vendor has not been verified" do
    
    it "should have the right links on the layout" do
      pending "until all the menu items have been designed - then also update section above"
    end
    
  end
  
  describe "when 'vendor_id' cookie is not set" do
    
    before(:each) do
      @vendor2 = Factory(:vendor, :name => "Vendor2", :country_id => @country.id)
      @representation2 = Factory(:representation, :user_id => @user.id, :vendor_id => @vendor2.id)
      integration_log_in(@user)
    end
    
    it "should have a different 'business home' link - including 'select a vendor'" do
      visit business_home_path
      response.should have_selector("a", :href => business_home_path, :content => "Home / select vendor")
    end
    
    it "should not have a supplier menu reference in the 'loginfo' div" do
      visit business_home_path
      response.should_not have_selector("div#loginfo", :content => "Menu:")
      response.should_not have_selector("div#loginfo", :content => @vendor2.name)
    end
    
    it "should not have a 'Vendor Profile' link" do
      visit business_home_path
      response.should_not have_selector("a", :content => "Vendor profile")  
    end
    
    it "should not have a 'Training resources' link" do
      visit business_home_path
      response.should_not have_selector("a", :content => "Training resources")  
    end 
  end
end
