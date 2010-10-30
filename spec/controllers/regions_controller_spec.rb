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
  
  describe "edit/update permissions for non-logged-in users" do
    
    before(:each) do
      @user = Factory(:user)
      @region = Factory(:region)
      @region_old = @region.region
      @region_new = "#{@region.region}_new"
    end
    
    it "should be impossible for non-logged-in users to access 'edit'" do
      get :edit, :id => @region
      response.should redirect_to(login_path)
    end
    
    it "should be impossible for non-logged-in users to update a region" do
      put :update, :id => @region
      @region.region.should == @region_old
      response.should redirect_to(login_path)
    end
    
    it "should be impossible for logged-in non-admin users to access 'edit'" do
      test_log_in(@user)
      get :edit, :id => @region
      response.should redirect_to(root_path)
    end
    
    it "should be impossible for logged-in non-admin users to update a region" do
      test_log_in(@user)
      put :update, :id => @region
      @region.region.should == @region_old
      response.should redirect_to(root_path)
      
    end
  end
  
  describe "edit and update actions for logged-in admin users" do
    
    before(:each) do
      @user = Factory(:user, :admin => true)
      @region = Factory(:region)
      @region_old = @region.region
      @region_new = "#{@region.region}_new"
      test_log_in(@user)
    end
    
    describe "GET 'edit'" do
      
      it "should be successful" do
        get :edit, :id => @region
        response.should be_success
      end  
        
      it "should have the right title" do
        get :edit, :id => @region
        response.should have_selector("title", :content => "Edit region")
      end
    end
    
    describe "PUT 'update'" do
      
      describe "failure" do
        
        before(:each) do
          @attr = { :region => "" }
        end
        
        it "should render the edit page" do
          put :update, :id => @region, :region => ""
          response.should render_template('edit')
        end
      end
      
      describe "success" do
        
      end
    end
  end
  
  describe "DELETE 'destroy'" do
    
    before(:each) do 
      @user = Factory(:user)
      @region = Factory(:region)
    end
    
    it "should be impossible for non-logged-in users" do
      lambda do
        delete :destroy, :id => @region 
        response.should redirect_to(login_path)
      end.should_not change(Region, :count)  
    end
    
    it "should be impossible for logged-in non-admins" do
      lambda do  
        test_log_in(@user)
        delete :destroy, :id => @region
        response.should redirect_to(root_path)
      end.should_not change(Region, :count)
    end
    
    describe "for logged-in admins" do
      
      before(:each) do
        test_log_in(Factory(:user, :email => "user@example.info", :admin => true))
      end
      
      it "should be successful if the region is not associated with any country" do
        
        #to be completed when Countries are included
        
        lambda do  
          delete :destroy, :id => @region
          response.should redirect_to(regions_path)
        end.should change(Region, :count).by(-1)
      end
      
      
      it "should be unsuccessful if the region is associated with any country" do
        
        #to be completed when Countries are included
        
      end
    end
  end
end
