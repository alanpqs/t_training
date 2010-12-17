require 'spec_helper'

describe "BusinessLinks" do
  
  before(:each) do
    @region = Factory(:region)
    @country = Factory(:country, :region_id => @region.id)
    @user = Factory(:user, :vendor => true, :country_id => @country.id)
    @vendor = Factory(:vendor, :country_id => @country.id)
    @representation = Factory(:representation, :user_id => @user.id, :vendor_id => @vendor.id)
    integration_log_in(@user)
  end
  
  it "should have the right links on the layout" do
    visit business_home_path
    click_link "Home"
    response.should have_selector('title', :content => "Training supplier - home")
    click_link "Vendor profile"
    response.should have_selector('title', :content => "#{@vendor.name}")
    click_link "Add a new vendor"
    response.should have_selector('title', :content => "New vendor")
    
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
