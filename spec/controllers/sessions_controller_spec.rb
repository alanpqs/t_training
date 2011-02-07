require 'spec_helper'

describe SessionsController do
  render_views
  
  describe "GET 'new'" do
    
    it "should be successful" do
      get :new
      response.should be_success
    end
  
    it "should have the right title" do
      get :new
      response.should have_selector("title", :content => "Log In")
    end
  end

  describe "POST 'create'" do
    
    describe "invalid login" do
    
      before(:each) do
        @attr = { :email => "email@example.com", :password => "invalid" }
      end
    
      it "should re-render the new page" do
        post :create, :session => @attr
        response.should render_template('new')
      end
    
      it "should have the right title" do
        post :create, :session => @attr
        response.should have_selector("title", :content => "Log In")
      end
    
      it "should have a flash.now message" do
        post :create, :session => @attr
        flash.now[:error].should =~ /invalid/i
      end
    end
    
    describe "with valid email and password" do
    
      before(:each) do
        @region = Factory(:region)
        @country = Factory(:country, :region_id => @region.id)
        @user = Factory(:user, :country_id => @country.id) 
        @attr = { :email => @user.email, :password => @user.password }
      end
      
      it "should sign the user in" do
        post :create, :session => @attr
        controller.current_user.should == @user
        controller.should be_logged_in
      end
      
      it "should redirect to the user show page" do
        post :create, :session => @attr
        response.should redirect_to(user_path(@user))
      end  
    end
  end
  
  describe "DELETE 'destroy'" do
    
    before(:each) do
      @region = Factory(:region)
      @country = Factory(:country, :region_id => @region.id)
      test_log_in(Factory(:user, :country_id => @country.id))
    end
    
    it "should log a user out" do
      delete :destroy
      controller.should_not be_logged_in
      response.should redirect_to(root_path)
    end
    
    it "should destroy any stored sessions" do
      session[:return_to] = why_register_path
      delete :destroy
      session[:return_to].should == nil
    end
  end
end
