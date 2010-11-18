require 'spec_helper'

describe "AdminLinks" do
  
  before(:each) do
    @user = Factory(:user, :admin => true)
    integration_log_in(@user)
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
    
end
