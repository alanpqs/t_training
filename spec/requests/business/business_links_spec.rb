require 'spec_helper'

describe "BusinessLinks" do
  
  before(:each) do
    @user = Factory(:user, :vendor => true)
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
