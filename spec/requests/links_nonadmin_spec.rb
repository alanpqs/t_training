require 'spec_helper'

describe "Links for users logged in but not admins" do

  before(:each) do
    @user = Factory(:user)
    integration_log_in(@user)
  end
    
  it "should have a logout link" do
    visit root_path
    response.should have_selector("a",  :href => logout_path,
                                       :content => "Log out")
  end
    
  it "should not have a users link" do
    visit root_path
    response.should_not have_selector("a",  :href => users_path,
                                            :content => "Users")  
  end
    
  it "should have a settings link" do
    visit root_path
    response.should have_selector("a",  :href => edit_user_path(@user),
                                        :content => "Settings")
  end
    
  it "should not have a login link" do
    visit root_path
    response.should_not have_selector("a",  :href => login_path,
                                            :content => "Log in")
  end
    
  it "should not have a signup link" do
    visit root_path
    response.should_not have_selector("a",  :href => signup_path,
                                            :content => "Sign up")
  end
    
  it "should not have a Find training link" do
    visit root_path
    response.should_not have_selector("a",  :href => find_training_path,
                                            :content => "Find training")
  end
    
  it "should not have a Why register link" do
    visit root_path
    response.should_not have_selector("a",  :href => why_register_path,
                                            :content => "Why register")
  end
    
  it "should not have an About link" do
    visit root_path
    response.should_not have_selector("a",  :href => about_path,
                                            :content => "About us")
  end
    
  it "should not have an FAQs link" do
    visit root_path
    response.should_not have_selector("a",  :href => faqs_path,
                                            :content => "FAQs")
  end
    
  it "should not have an Introduction to Why Register" do
    visit root_path
    response.should_not have_selector("a",  :href => why_register_path,
                                            :content => "Introduction")
  end
    
  it "should not have a Buying training link" do
    visit root_path
    response.should_not have_selector("a",  :href => buyers_path,
                                            :content => "Buying training")
  end
    
  it "should not have a Selling training link" do
    visit root_path
    response.should_not have_selector("a",  :href => sellers_path,
                                            :content => "Selling training")
  end
    
  it "should not have a Becoming an affiliate link" do
    visit root_path
    response.should_not have_selector("a",  :href => affiliates_path,
                                            :content => "Becoming an affiliate")
  end
    
  it "should not have a Terms and Conditions link" do
    visit root_path
    response.should_not have_selector("a",  :href => terms_path,
                                            :content => "Terms and Conditions")
  end
     
  it "should have a current_user.name" do
    visit root_path
    response.should have_selector("div#loginfo", :content => @user.name)
  end
    
  it "should not have a Regions link" do
    visit root_path
    response.should_not have_selector("a",  :href => admin_regions_path,
                                            :content => "Regions")
  end

end
