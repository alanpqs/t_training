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
        
        it "should have a 'New region' link" do
          get :index
          response.should have_selector("a",    :href     => "/regions/new",
                                                :content  => "New region")
        end
        
        before(:each) do
          @country_attr = { :name => "AAA", :country_code => "AAA", :currency_code => "USD",
                          :phone_code => "+567", :region_id => 1 }
        end
        
        it "should have a delete link if no countries belong to the region" do
          Country.create!(@country_attr)
          @regions = Region.all
          @regions.each do |region|
            c_count = Country.count(:conditions => ["region_id = ?", region.id])
            if c_count == 0
              get :index
              response.should have_selector("a",  :href => "/regions/#{region.id}",
                                                  :content => "delete")
            end
          end
        end
        
        it "should not have a delete link if any countries belong to the region" do
          Country.create!(@country_attr)
          @regions = Region.all
          @regions.each do |region|
            c_count = Country.count(:conditions => ["region_id = ?", region.id])
            if c_count > 0
              get :index
              response.should_not have_selector("a",  :href => "/regions/#{region.id}",
                                                      :content => "delete")
            end
          end 
        end   
      end
    end
  end

  
  
  describe "deny new/create permissions to non-logged-in and non-admin users" do
    
    before(:each) do
      @user = Factory(:user)
      @attr = { :region => "Some Region"}
    end
    
    describe "for non-logged in users" do 
      it "should deny access to 'New' to non-logged-in users" do
        get 'new'
        response.should_not be_success
      end
    
      it "should redirect a non-logged-in user to the login path if 'New' is attempted" do
        get 'new'
        response.should redirect_to(login_path)
      end
    
      it "should prevent a non-logged-in user from adding a new region" do
        lambda do
          post :create, :region => @attr
        end.should_not change(Region, :count)   
      end
    
      it "should redirect a non-logged-in user to the root path if a create is attempted" do
        post :create, :region => @attr
        response.should redirect_to(root_path)
      end
    
      it "should display a 'Permission denied' notice when a non-logged-in user attempts 'Create'" do
        post :create, :region => @attr
        flash[:notice].should =~ /Permission denied/i
      end
    end
    
    describe "for logged-in non-admins" do
     
      before(:each) do
        test_log_in(@user)
      end 
      
      it "should deny access to 'New' to logged-in non-admins" do
        get 'new'
        response.should_not be_success
      end
    
      it "should redirect a logged-in non-admin to the root path if 'New' is attempted" do
        get 'new'
        response.should redirect_to(root_path)
      end
    
      it "should prevent a logged-in non-admin from adding a new region" do
        lambda do
          post :create, :region => @attr
        end.should_not change(Region, :count)   
      end
    
      it "should redirect a logged-in non-admin to the root path if a create is attempted" do
        post :create, :region => @attr
        response.should redirect_to(root_path)
      end
    
      it "should display a 'Permission denied' notice when a logged-in non-admin attempts 'Create'" do
        post :create, :region => @attr
        flash[:notice].should =~ /Permission denied/i
      end  
    end
  end
  
  
  
  describe "GET 'new' for logged-in admin users" do
    
    before(:each) do
      @user = Factory(:user, :admin => true)
      test_log_in(@user)
    end
  
    it "should open successfully" do
      get :new
      response.should be_success
    end
    
    it "should have the right title" do
      get :new
      response.should have_selector("title", :content => "New region")
    end
    
  end
  
  describe "POST 'create' for logged-in admin users" do
    
    before(:each) do
      @user = Factory(:user, :admin => true)
      @attr_blank = { :region => "" }
      @attr_good  = { :region => "New region"}
      test_log_in(@user)
    end
    
    describe "failure" do
      
      it "should not create a new region" do
        lambda do
          post :create, :region => @attr_blank
        end.should_not change(Region, :count)
      end
      
      it "should display an error message" do
          post :create, :region => @attr_blank
          response.should have_selector("div#error_explanation", :content => "There were problems")
      end
      
      it "should have the right title" do
        post :create, :region => @attr_blank
        response.should have_selector("title", :content => "New region")
      end
      
      it "should redirect to the 'new' page" do
        post :create, :region => @attr_blank
        response.should render_template("new")
      end
    end
    
    describe "success" do
      
      it "should create a new region" do
        lambda do
          post :create, :region => @attr_good
        end.should change(Region, :count).by(1)  
      end
      
      it "should have a success message" do
        post :create, :region => @attr_good
        flash[:success].should =~ /Region created/i      
      end
      
      it "should redirect to the regions list" do
        post :create, :region => @attr_good
        response.should redirect_to(regions_path)
      end
    end
    
  end
  
  
  
  describe "deny edit/update permissions to non-logged-in and non-admin users" do
    
    before(:each) do
      @user = Factory(:user)
      @region = Factory(:region)
      @attr = { :region => "New Region" }
    end
    
    it "should be impossible for non-logged-in users to access 'edit'" do
      get :edit, :id => @region
      response.should redirect_to(login_path)
    end
    
    it "should be impossible for non-logged-in users to update a region" do
      put :update, :id => @region, :region => @attr
      @region.reload
      @region.region.should_not == @attr[:region]
    end
    
    it "should redirect non-logged-in users to the root path when Update is attempted" do
      put :update, :id => @region, :region => @attr
      response.should redirect_to(root_path)
    end
    
    it "should display a 'Permission denied' notice when a non-logged-in user attempts 'Update'" do
      put :update, :id => @region, :region => @attr
      flash[:notice].should =~ /Permission denied/i
    end
    
    it "should be impossible for logged-in non-admin users to access 'edit'" do
      test_log_in(@user)
      get :edit, :id => @region
      response.should redirect_to(root_path)
    end
    
    it "should be impossible for logged-in non-admin users to update a region" do
      test_log_in(@user)
      put :update, :id => @region, :region => @attr
      @region.reload
      @region.region.should_not == @attr[:region] 
    end
    
    it "should redirect logged-in non-admin users to the root path when Update is attempted" do
      test_log_in(@user)
      put :update, :id => @region, :region => @attr
      response.should redirect_to(root_path)
    end
    
    it "should display a 'Permission denied' notice when a logged-in non-admin attempts 'Update'" do
      put :update, :id => @region, :region => @attr
      flash[:notice].should =~ /Permission denied/i
    end
  end
  
  
  
  describe "edit and update actions for logged-in admin users" do
    
    before(:each) do
      @user = Factory(:user, :admin => true)
      @region = Factory(:region)
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
          put :update, :id => @region, :region => @attr
          response.should render_template('edit')
        end
        
        it "should have the right title" do
          put :update, :id => @region, :region => @attr
          response.should have_selector("title", :content => "Edit region")
        end
      
        it "should not change the region's attributes" do
          put :update, :id => @region, :user => @attr
          @region.reload
          @region.region.should_not == @attr[:region]
        end
      end
      
      describe "success" do
        
        before(:each) do
          @attr = { :region => "New Region" }
        end
      
        it "should change the user's attributes" do
          put :update, :id => @region, :region => @attr
          @region.reload
          @region.region.should == @attr[:region]
        end
      
        it "should redirect to the Region index page" do
          put :update, :id => @region, :region => @attr
          response.should redirect_to(regions_path)
        end
      
        it "should have a flash message" do
          put :update, :id => @region, :region => @attr
          flash[:success].should =~ /updated/
        end
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
        @attr2 = { :region => "Asia"}
        @country_attr = { :name => "India", :country_code => "IND", :currency_code => "IRP",
                          :phone_code => "+091", :region_id => 1 }
        test_log_in(Factory(:user, :email => "user@example.info", :admin => true))
      end
      
      describe "success" do
      
        it "should delete the region if it is not associated with any country" do
          Region.create!(@attr2)
          Country.create!(@country_attr)
          @region2 = Region.find_by_region("Asia")
  
          lambda do  
            delete :destroy, :id => @region2
            response.should redirect_to(regions_path)
          end.should change(Region, :count).by(-1)
        end
        
        it "should display a success message" do
          Region.create!(@attr2)
          Country.create!(@country_attr)
          @region2 = Region.find_by_region("Asia")
          delete :destroy, :id => @region2
          flash[:success].should == "Asia deleted."
        end
        
        it "should redirect to the region 'index'" do
          Region.create!(@attr2)
          Country.create!(@country_attr)
          @region2 = Region.find_by_region("Asia")
          delete :destroy, :id => @region2
          response.should redirect_to(regions_path)
        end
        
      end
      
      describe "failure" do
      
        it "should not delete the region if it is associated with any country" do
          Region.create!(@attr2)
          Country.create!(@country_attr)
          
          lambda do  
            delete :destroy, :id => @region
          end.should_not change(Region, :count)
        end
        
        it "should display a failure notice" do
          Region.create!(@attr2)
          Country.create!(@country_attr)
          delete :destroy, :id => @region
          flash[:error].should == "Cannot delete #{@region.region} - linked to countries."
        end
        
        it "should redirect to the region 'index'" do
          Region.create!(@attr2)
          Country.create!(@country_attr)
          delete :destroy, :id => @region
          response.should redirect_to(regions_path)
        end
      end
    end
  end
end
