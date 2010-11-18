require 'spec_helper'

describe Admin::PagesController do
  render_views
  
  before(:each) do
    @base_title = "Tickets for Training"
  end
  
  describe "for non-logged-in users" do
    
    describe "GET 'home'" do
      
      it "should not be successful" do
        get :home
        response.should_not be_success
      end
    
      it "should redirect to the log-in page" do
        get :home
        response.should redirect_to(login_path)
      end
    end
  end
  
  describe "for logged-in non-admins" do
    
    before(:each) do
      @user = Factory(:user)
      test_log_in(@user)
    end
    
    describe "GET 'home'" do
      
      it "should not be successful" do
        get :home
        response.should_not be_success
      end
      
      it "should redirect to the root-path" do
        get :home
        response.should redirect_to(root_path)
      end
    end
  end
  
  describe "for logged-in admins" do
    
    before(:each) do
      @user = Factory(:user, :admin => true)
      test_log_in(@user)
    end
    
    describe "GET 'home'" do
      
      it "should be successful" do
        get :home
        response.should be_success
      end
      
      it "should have the right title" do
        get :home
        response.should have_selector("title",
              :content => @base_title + " | Admin home-page")
      end
        
      it "should have the right side-bar links for an admin user" do
        get :home
        response.should have_selector("a",  :href => admin_regions_path, :content => "Regions")
      end
      
      it "should have a 'Home' link which points back to the Admin home-page" do
        get :home
        response.should have_selector("a",  :href => admin_home_path, :content => "Home")
      end
    end
  end
end
