require 'spec_helper'

describe "AdminLinks" do
  
  before(:each) do
    @user = Factory(:user, :admin => true)
    integration_log_in(@user)
  end
  
  it "should have the right links on the layout" do
    visit admin_home_path
    click_link "Users"
    response.should have_selector("title", :content => "All users")
    click_link "Regions"
    response.should have_selector("title", :content => "Regions")
    click_link "Countries"
    response.should have_selector("title", :content => "Countries")
    click_link "Categories"
    response.should have_selector("title", :content => "Training categories")
    click_link "Training media"
    response.should have_selector("title", :content => "Training media") 
  end
    
    
  it "should have a users link" do
    visit admin_home_path
    response.should have_selector("a",  :href => admin_users_path,
                                          :content => "Users")  
  end
    
  it "should have a Regions link" do
    visit admin_home_path
    response.should have_selector("a",  :href => admin_regions_path,
                                          :content => "Regions")
  end
  
  it "should have a Countries link" do
    visit admin_home_path
    response.should have_selector("a",  :href => admin_countries_path,
                                        :content => "Countries")
  end
  
  it "should have a Training media link" do
    visit admin_home_path
    response.should have_selector("a",  :href => admin_media_path,
                                        :content => "Training media")
  end                                     
end
