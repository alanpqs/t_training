require 'spec_helper'

describe Business::PagesController do

  render_views
  
  before(:each) do
    @region = Factory(:region)
    @country = Factory(:country, :region_id => @region.id)
    @user = Factory(:user, :country_id => @country.id)
    @provider = Factory(:user,  :name => "Provider", :email => "provider@email.com", 
                                :vendor => true, :country_id => @country.id)  
  end
  
  describe "for non-logged-in users" do
    
    describe "GET 'home'" do
      
      it "should not be successful" do
        get :home
        response.should_not be_success
      end
      
      it "should redirect to the login page" do
        get :home
        response.should redirect_to login_path
      end
    end
  end
  
  describe "for logged-in users without a vendor attribute" do
    
    before(:each) do
      test_log_in(@user)
    end
    
    describe "GET 'home'" do
      
      it "should not be successful" do
        get :home
        response.should_not be_success
      end
      
      it "should redirect to the user home page" do
        get :home
        response.should redirect_to user_path(@user)
      end
      
      it "should have a message explaining how to sign up as a vendor" do
        get :home
        flash[:notice].should =~ /If you want to sell training/
      end
    end
  end
  
  describe "for logged-in users with the vendor attribute set to true" do
    
    before(:each) do
      test_log_in(@provider)
    end
    
    describe "GET 'home'" do
      
      it "should be successful" do
        get :home
        response.should be_success
      end
      
      it "should have the right title" do
        get :home
        response.should have_selector("title",  :content => "Training supplier - home")
      end
      
      describe "if the logged in user does not represent a vendor yet" do
        
        it "should display a partial asking the user to add associated vendors" do
          get :home
          response.should have_selector("p", 
              :content => "You're not associated with any training businesses yet")
        end
      end
      
      describe "if the logged-in user already represents at least one vendor" do
        
        before(:each) do
          @vendor = Factory(:vendor, :country_id => @country.id)
          @representation = Factory(:representation, :user_id => @provider.id, :vendor_id => @vendor.id)
        end
        
        it "should display a partial listing vendors represented by the user" do
          get :home
          response.should have_selector("p", :content => "You currently represent")
        end
      end
    end
  end
end
