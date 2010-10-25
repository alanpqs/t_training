require 'spec_helper'

describe "LayoutLinks" do
  it "should have a Home page at '/'" do
    get '/'
    response.should have_selector('title', :content => "Home")
  end
  
  it "should have a Why Register page at '/why_register'" do
    get '/why_register'
    response.should have_selector('title', :content => "Why Register")
  end
  
  it "should have an About page at '/about'" do
    get '/about'
    response.should have_selector('title', :content => "About")
  end
  
  it "should have an FAQs page at '/faqs'" do
    get '/faqs'
    response.should have_selector('title', :content => "FAQs")
  end
  
  it "should have a Find training page at '/find_training'" do
    get '/find_training'
    response.should have_selector('title', :content => "Find Training") 
  end
  
  it "should have a Signup page at '/signup'" do
    get '/signup'
    response.should have_selector('title', :content => "Sign Up")
  end
  
  it "should have a Login page at '/login'" do
    get '/login'
    response.should have_selector('title', :content => "Log In")
  end
  
  it "should have a Buyers page at '/buyers'" do
    get '/buyers'
    response.should have_selector('title', :content => "Buyers")
  end
  
  it "should have a Sellers page at '/sellers'" do
    get '/sellers'
    response.should have_selector('title', :content => "Sellers")
  end
  
  it "should have an Affiliates page at '/affiliates'" do
    get '/affiliates'
    response.should have_selector('title', :content => "Affiliates")
  end
  
  it "should have a Terms page at '/terms'" do
    get '/terms'
    response.should have_selector('title', :content => "Terms")
  end
  
  it "should have the right links on the layout" do
    visit root_path
    click_link "About"
    response.should have_selector('title', :content => "About")
    click_link "Home"
    response.should have_selector('title', :content => "Home")
    click_link "Why register"
    response.should have_selector('title', :content => "Why Register")
    click_link "FAQs"
    response.should have_selector('title', :content => "FAQs")
    click_link "Find training"
    response.should have_selector('title', :content => "Find Training")
    click_link "Sign up"
    response.should have_selector('title', :content => "Sign Up")
    click_link "Log in"
    response.should have_selector('title', :content => "Log In")
  end
  
  describe "when not logged in" do
    
    it "should have a login link" do
      visit root_path
      response.should have_selector("a",  :href => login_path,
                                          :content => "Log in")
    end
    
    it "should have a signup link" do
      visit root_path
      response.should have_selector("a",  :href => signup_path,
                                          :content => "Sign up")
    end
    
    it "should have a Find training link" do
      visit root_path
      response.should have_selector("a",  :href => find_training_path,
                                          :content => "Find training")
    end
    
    it "should have a Why register link" do
      visit root_path
      response.should have_selector("a",  :href => why_register_path,
                                          :content => "Why register")
    end
    
    it "should have an About link" do
      visit root_path
      response.should have_selector("a",  :href => about_path,
                                          :content => "About us")
    end
    
    it "should have an FAQs link" do
      visit root_path
      response.should have_selector("a",  :href => faqs_path,
                                          :content => "FAQs")
    end
    
    it "should have an Introduction to Why Register" do
      visit root_path
      response.should have_selector("a",  :href => why_register_path,
                                          :content => "Introduction")
    end
    
    it "should have a Buying training link" do
      visit root_path
      response.should have_selector("a",  :href => buyers_path,
                                          :content => "Buying training")
    end
    
    it "should have a Selling training link" do
      visit root_path
      response.should have_selector("a",  :href => sellers_path,
                                          :content => "Selling training")
    end
    
    it "should have a Becoming an affiliate link" do
      visit root_path
      response.should have_selector("a",  :href => affiliates_path,
                                          :content => "Becoming an affiliate")
    end
    
    it "should have a Terms and Conditions link" do
      visit root_path
      response.should have_selector("a",  :href => terms_path,
                                          :content => "Terms and Conditions")
    end
    
  end
  
  describe "when logged in" do
    
    before(:each) do
      @user = Factory(:user)
      visit login_path
      fill_in :email,             :with => @user.email
      fill_in :password,          :with => @user.password 
      click_button
    end
    
    it "should have a logout link" do
      visit root_path
      response.should have_selector("a",  :href => logout_path,
                                          :content => "Log out")
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
     
    it "should have a profile link" do
      visit root_path
      response.should have_selector("a",  :href => user_path(@user),
                                          :content => "Profile")
    end
    
  end
end
