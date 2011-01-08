require 'spec_helper'

describe Business::MediaController do

  render_views
  
  before(:each) do
    @region = Factory(:region)
    @country = Factory(:country, :region_id => @region.id)
    @user = Factory(:user, :country_id => @country.id, :vendor => true)
    @nonvendor_user = Factory(:user, :email => "nonvendor@example.com", :country_id => @country.id)
    @vendor = Factory(:vendor, :country_id => @country.id)
    @representation = Factory(:representation, :user_id => @user.id, :vendor_id => @vendor.id)
    @medium1 = Factory(:medium, :user_id => @user.id)
    @medium2 = Factory(:medium, :medium => "Efg", :user_id => @user.id, :authorized => true)
    @medium3 = Factory(:medium, :medium => "Hij", :user_id => @user.id)
    @media = [@medium1, @medium2, @medium3] 
  end
 
  describe "for non-logged-in users" do
    
    describe "GET 'new'" do
      
      it "should not be successful" do
        get :new
        response.should_not be_success
      end
      
      it "should redirect to the login page" do
        get :new
        response.should redirect_to login_path
      end
    end
    
    describe "POST 'create'" do
      
      before(:each) do
        @attr = { :medium => "Biff", :user_id => @user.id }
      end
      
      it "should not add a new medium" do
        lambda do
          post :create, :medium => @attr
        end.should_not change(Medium, :count)  
      end
    
      it "should redirect to the root path" do
        post :create, :medium => @attr
        response.should redirect_to root_path
      end
      
      it "should display a warning" do
        post :create, :medium => @attr
        flash[:notice].should =~ /Permission denied/
      end
    end
    
  end
  
  describe "for logged-in non-vendors" do
    
    before(:each) do
      test_log_in(@nonvendor_user)
    end
    
    describe "GET 'new'" do
      
      it "should not be successful" do
        get :new
        response.should_not be_success
      end
      
      it "should redirect to the user home page" do
        get :new
        response.should redirect_to @nonvendor_user
      end
      
      it "should display a warning" do
        get :new
        flash[:notice].should =~ /If you want to sell training/
      end
    end
    
    describe "POST 'create'" do
      
      before(:each) do
        @attr = { :medium => "Biff", :user_id => @nonvendor_user.id }
      end
      
      it "should not add a new medium" do
        lambda do
          post :create, :medium => @attr
        end.should_not change(Medium, :count)  
      end
    
      it "should redirect to the root path" do
        post :create, :medium => @attr
        response.should redirect_to root_path
      end
      
      it "should display a warning" do
        post :create, :medium => @attr
        flash[:notice].should =~ /Permission denied/
      end
    end
    
    
  end
  
  describe "for logged-in vendors" do
    
    before(:each) do
      
      test_log_in(@user)
      session[:return_to] = new_vendor_resource_path(@vendor)
    end
    
    describe "GET 'new'" do
    
      it "should be successful" do
        get :new
        response.should be_success
      end
      
      it "should have the right title" do
        get :new
        response.should have_selector("title", :content => "Suggest a new format")
      end
      
      it "should have a text-box for the suggested medium" do
        get :new
        response.should have_selector("input", :name => "medium[medium]",
                                               :content => "")
      end
      
      it "should have a hidden field referencing the current user's id" do
        get :new
        response.should have_selector("input", :name => "medium[user_id]",
                                               :type => "hidden",
                                               :value => @user.id.to_s)
      end
      
      it "should have a 'Create' button" do
        get :new
        response.should have_selector("input", :type => "submit",
                                               :value => "Send your suggestion")
      end
      
      it "should contain a list of current formats, including those waiting approval" do
        get :new
        @media.each do |medium|
          response.should have_selector("li", :content => medium.medium)
        end  
      end
      
      it "should italicize unapproved formats in the current format list" do
        get :new
        response.should have_selector("i", :content => @medium3.medium)  
      end 
      
      it "should have a 'return without changes' link" do
        get :new
        response.should have_selector("a",  :href => new_vendor_resource_path(@vendor),
                                            :content => "no suggestions - back to previous form") 
      end
    end

    describe "POST 'create'" do
      
      before(:each) do
        @good_attr = { :medium => "Biff", :user_id => @user.id }
        @bad_attr =  { :medium => "", :user_id => @user.id }
      end
      
      describe "success" do
      
        it "should create a new medium" do
          lambda do
            post :create, :medium => @good_attr
          end.should change(Medium, :count).by(1)  
        end
      
        it "should not be 'authorized'" do
          post :create, :medium => @good_attr
          @posted_medium = Medium.find(:last)
          @posted_medium.authorized.should == false
        end
        
        it "should redirect to the stored vendor page" do
          post :create, :medium => @good_attr
          response.should redirect_to new_vendor_resource_path(@vendor)
        end
        
        it "should display a success message, explaining email notification" do
          post :create, :medium => @good_attr
          flash[:success].should =~ /We'll respond soon by email/
        end
      end
      
      describe "failure" do
        
        it "should not create a new medium" do
          lambda do
            post :create, :medium => @bad_attr
          end.should_not change(Medium, :count)  
        end
        
        it "should redisplay the 'new' page" do
          post :create, :medium => @bad_attr
          response.should render_template("new")
        end
        
        it "should display an error message" do
          post :create, :medium => @bad_attr
          response.should have_selector("div#error_explanation", :content => "There were problems")
        end
        
        it "should have the right title" do
          post :create, :medium => @bad_attr
          response.should have_selector("title", :content => "Suggest a new format")
        end
      end
    end
  end
end
