require 'spec_helper'

describe RegionsController do
  render_views

  describe "GET 'index'" do
    
    it "should deny access to non-logged-in users" do
      get :index
      response.should_not be_success
    end
    
    it "should deny access to logged-in non-admin users" do
      user = Factory(:user)
      test_log_in(user)
      get :index
      response.should_not be_success
    end
    
    describe "for logged-in admin users" do
      before(:each) do
        @attrs = ["Europe", "Asia", "America"]
        @attrs.each do |attr|
          Region.create!(:region => attr)
        end
        admin_user = Factory(:user, :admin => true)
        test_log_in(admin_user)
      end
      
      describe "accessible to admins" do
      
        it "should be successful for logged-in admin users" do 
          get :index
          response.should be_success
        end
      
        it "should have the right title" do
          get :index
          response.should have_selector("title", :content => "Regions")
        end
        
        it "should have an element for each user" do
          @regions = Region.all
          @regions.each do |region|
            get :index
            response.should have_selector("li", :content => region.region)
          end
        end
      end
    end
  end

  describe "GET 'new'" do
    it "should not be successful for non-logged-in users" do
      get 'new'
      response.should_not be_success
    end
  end
end
