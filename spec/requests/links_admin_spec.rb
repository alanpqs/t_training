require 'spec_helper'

describe "Layout links for those logged in as admins" do
  
  before(:each) do
    @user = Factory(:user, :admin => true)
    integration_log_in(@user)
  end
    
  it "should have a users link" do
    visit root_path
    response.should have_selector("a",  :href => users_path,
                                        :content => "Users")  
  end
    
  it "should have a Regions link" do
    visit root_path
    response.should have_selector("a",  :href => regions_path,
                                        :content => "Regions")
  end
  
  it "should have the right links on the layout" do
    visit root_path
    click_link "Regions"
    response.should have_selector("title", :content => "Regions")
  end
    
end
