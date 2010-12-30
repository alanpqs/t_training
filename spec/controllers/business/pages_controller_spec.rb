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
    
    describe "GET 'resource_group'" do
      
      it "should not be successful" do
        get :resource_group
        response.should_not be_success
      end
      
      it "should redirect to the login page" do
        get :resource_group
        response.should redirect_to login_path
      end
    end
    
    describe "GET 'duplicate resource to vendor'" do
      
      it "should not be successful" do
        get :duplicate_resource_to_vendor
        response.should_not be_success
      end
      
      it "should redirect to the login page" do
        get :duplicate_resource_to_vendor
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
    
    describe "GET 'resource_group'" do
      
      it "should not be successful" do
        get :resource_group
        response.should_not be_success
      end
      
      it "should redirect to the user home page" do
        get :resource_group
        response.should redirect_to user_path(@user)
      end
      
      it "should have a message explaining how to sign up as a vendor" do
        get :resource_group
        flash[:notice].should =~ /If you want to sell training/
      end
    end
    
    describe "GET 'duplicate resource to vendor'" do
      
      it "should not be successful" do
        get :duplicate_resource_to_vendor
        response.should_not be_success
      end
      
      it "should redirect to the user home page" do
        get :duplicate_resource_to_vendor
        response.should redirect_to user_path(@user)
      end
      
      it "should have a message explaining how to sign up as a vendor" do
        get :duplicate_resource_to_vendor
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
        
        it "should not have a 'vendor' cookie" do
          get :home
          response.cookies["vendor_id"].should == nil
        end
      end
      
      describe "if the logged-in user represents only one vendor" do
        
        before(:each) do
          @vendor = Factory(:vendor, :country_id => @country.id)
          @representation = Factory(:representation, :user_id => @provider.id, :vendor_id => @vendor.id)
        end
        
        it "should display a partial listing the vendor represented by the user" do
          get :home
          response.should have_selector("li", :content => @vendor.name)
        end
        
        it "should have the vendor.id stored as a cookie" do
          get :home
          response.cookies["vendor_id"].should == "#{@vendor.id}"
        end
      end
      
      describe "if the logged-in user represents more than one vendor" do
        
        before(:each) do
          @vendor = Factory(:vendor, :country_id => @country.id)
          @vendor2 = Factory(:vendor, :name => "Vendor2", :country_id => @country.id,
                                      :address => "Oxford", :email => "vendor2@example.com")
          @representation1 = Factory(:representation, :user_id => @provider.id, :vendor_id => @vendor.id)
          @representation2 = Factory(:representation, :user_id => @provider.id, :vendor_id => @vendor2.id)
          @reps = [@representation1, @representation2]
        end
        
        it "should display a partial listing all the vendors represented by the user" do
          get :home
          @reps.each do |rep|
            response.should have_selector("li", :content => rep.vendor.name)
          end
        end
        
        it "should not have a stored vendor cookie yet" do
          get :home
          response.cookies["vendor_id"].should == nil
        end
      end
    end
    
    
    describe "GET 'resource_group'" do
      
      before(:each) do
        @vendor = Factory(:vendor, :country_id => @country.id)
        @vendor2 = Factory(:vendor, :name => "vendor2", :country_id => @country.id)
      end
      
      describe "if the 'vendor_id' cookie is set" do
        
        before(:each) do
          @representation = Factory(:representation, :user_id => @provider.id, :vendor_id => @vendor2.id)
          test_vendor_cookie(@provider)
          @groups = ["Business", "Job", "Personal", "World", "Fun"]
        end
        
        it "should be successful" do
          get :resource_group
          response.should be_success
        end
      
        it "should have the right title" do
          get :resource_group
          response.should have_selector("title",  :content => "New resource - select a group")
        end
        
        it "should have a radio button for each group" do
          get :resource_group
          @groups.each do |group|
            response.should have_selector("input",  :name => "group",
                                                    :type => "radio",
                                                    :value => "#{group}")
          end
        end
        
        it "should have a link to the new vendor resource path for this vendor" do
          get :resource_group
          response.should have_selector("input", :type => "submit", :value => "Confirm")
        end
      end
      
      describe "if the 'vendor_id' cookie is not set" do
      
        it "should not be successful" do
          get :resource_group
          response.should_not be_success
        end
        
        it "should redirect to the business_home page" do
          get :resource_group
          response.should redirect_to business_home_path
        end  
        
        describe "if the user has no associated vendors" do
          
          it "should warn the user to add at least one vendor" do
            get :resource_group
            flash[:error].should == "First you need to add at least one vendor business." 
          end
          
        end
        
        describe "if the user has associated vendors" do
          
          before(:each) do
            @representation = Factory(:representation, :user_id => @provider.id, :vendor_id => @vendor2.id)
          end 
          it "should tell the user to select a vendor" do
            get :resource_group
            flash[:error].should == "First you need to select one of your vendor businesses."
          end
        end
      end
    end
    
    describe "GET 'duplicate resource to vendor'" do
      
      before(:each) do
        @vendor = Factory(:vendor, :country_id => @country.id, :verified => true)
        @vendor2 = Factory(:vendor, :name => "vendor2", :country_id => @country.id)
        @vendor3 = Factory(:vendor, :name => "vendor3", :country_id => @country.id)
        @vendor4 = Factory(:vendor, :name => "vendor4", :verified => true, :country_id => @country.id)
        @vendor5 = Factory(:vendor, :name => "vendor5", :verified => true, :country_id => @country.id)
        @category = Factory(:category, :user_id => @provider.id, :authorized => true)
        @medium = Factory(:medium, :user_id => @provider.id, :authorized => true)
        @resource1 = Factory(:resource, :vendor_id => @vendor.id, :category_id => @category.id, 
                                    :medium_id => @medium.id)
        @dup_resource1 = Factory(:resource, :vendor_id => @vendor2.id, :category_id => @category.id, 
                                    :medium_id => @medium.id)                            
        @resource2 = Factory(:resource, :name => "Resource2", :vendor_id => @vendor.id, 
                                  :category_id => @category.id, :medium_id => @medium.id)
        @dup_resource2 = Factory(:resource, :name => "Resource2", :vendor_id => @vendor2.id, 
                                  :category_id => @category.id, :medium_id => @medium.id)
      end
      
      describe "if the 'vendor_id' cookie is set" do
        
        before(:each) do
          @representation = Factory(:representation, :user_id => @provider.id, :vendor_id => @vendor.id)
          @representation2 = Factory(:representation, :user_id => @provider.id, :vendor_id => @vendor2.id)
          @representation3 = Factory(:representation, :user_id => @provider.id, :vendor_id => @vendor3.id)
          @representation4 = Factory(:representation, :user_id => @provider.id, :vendor_id => @vendor4.id)
          test_selected_vendor_cookie(@vendor.id)
        end
        
        describe "and if the 'resource_id' cookie is set" do
          
          before(:each) do
            test_resource_cookie(@resource1.id)
          end
          
          it "should be successful" do
            get :duplicate_resource_to_vendor
            response.should be_success
          end
          
          it "should have the right title" do
            get :duplicate_resource_to_vendor
            response.should have_selector("title", :content => "Duplicate resource to vendor")
          end
          
          it "should contain a reference to the resource name" do
            get :duplicate_resource_to_vendor
            response.should have_selector("h4", :content => "Resource: #{@resource1.name}")
          end
          
          it "should list vendors offering the resource" do
            get :duplicate_resource_to_vendor
            response.should have_selector("li", :content => @vendor.name)
            response.should have_selector("li", :content => @vendor2.name)
          end
          
          it "should have a table list for vendors not offering the resource" do
            get :duplicate_resource_to_vendor
            response.should have_selector("td", :content => @vendor3.name)
            response.should have_selector("td", :content => @vendor4.name)
          end
          
          it "should not include in the table list vendors not associated with the user" do
            get :duplicate_resource_to_vendor
            response.should_not have_selector("td", :content => @vendor5.name)
          end
          
          it "should have a 'duplicate' link for vendors not offering the resource" do
            get :duplicate_resource_to_vendor
            response.should have_selector("a", :href => "/duplicate_to_vendor?id=#{@vendor3.id}")
            response.should have_selector("a", :href => "/duplicate_to_vendor?id=#{@vendor4.id}")
          end
          
          it "should not have a 'duplicate' link for vendors offering the resource" do
            get :duplicate_resource_to_vendor
            response.should_not have_selector("a", :href => "/duplicate_to_vendor?id=#{@vendor.id}")
            response.should_not have_selector("a", :href => "/duplicate_to_vendor?id=#{@vendor2.id}")
          end
        end
        
        describe "or if the 'resource_id' cookie is not set" do
          
          it "should not be successful" do
            get :duplicate_resource_to_vendor
            response.should_not be_success
          end
          
        end
      end
      
      describe "if the 'vendor_id' cookie is not set" do
        
        it "should not be successful" do
          get :duplicate_resource_to_vendor
          response.should_not be_success
        end
      end
    end    
  end
end
