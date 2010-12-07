require 'spec_helper'

describe "BusinessLinks" do
  
  before(:each) do
    @user = Factory(:user, :vendor => true)
    integration_log_in(@user)
  end
  
  it "should have a new vendors link" do
    visit business_home_path
    response.should have_selector("a",  :href => new_business_vendor_path,
                                          :content => "Add a new vendor")  
  end
end
