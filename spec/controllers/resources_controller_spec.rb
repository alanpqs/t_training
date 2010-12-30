require 'spec_helper'

describe ResourcesController do

  render_views
  
  before(:each) do
    @region = Factory(:region)
    @country = Factory(:country, :region_id => @region.id)
    @user = Factory(:user, :country_id => @country.id, :vendor => true)
    @vendor = Factory(:vendor, :country_id => @country.id)
    @vendor2 = Factory(:vendor, :name => "Vendor2", :country_id => @country.id, :verified => true)   
    @representation = Factory(:representation, :user_id => @user.id, :vendor_id => @vendor2.id) 
    @category1 = Factory(:category, :user_id => @user.id, :authorized => true)
    @category2 = Factory(:category, :user_id => @user.id, :category => "HS", :authorized => true)
    @category3 = Factory(:category, :user_id => @user.id, :category => "HT", :authorized => true)
    
    @category4 = Factory(:category, :user_id => @user.id, :category => "HU", :target => "Fun", 
                         :authorized => true )
    @categories = [@category1, @category2, @category3, @category4]
    @medium1 = Factory(:medium, :user_id => @user.id, :authorized => true)
    @medium2 = Factory(:medium, :medium => "Fgh", :user_id => @user.id, :authorized => true)
    @medium3 = Factory(:medium, :medium => "Jkl", :user_id => @user.id)
    @media = [@medium1, @medium2, @medium3]
    @resource1 = Factory(:resource, :vendor_id => @vendor2.id, :category_id => @category1.id, 
                                    :medium_id => @medium1.id)
    @resource2 = Factory(:resource, :name => "Resource2", :vendor_id => @vendor2.id, 
                                    :category_id => @category1.id, :webpage => "webpage@example.com",
                                    :medium_id => @medium1.id, :description => "It's a")
    @resource3 = Factory(:resource, :name => "Resource3", :vendor_id => @vendor2.id, 
                                    :category_id => @category1.id, 
                                    :medium_id => @medium1.id)
    @other_vendor_resource = Factory(:resource, :name => "Resource4", :vendor_id => @vendor.id, 
                                    :category_id => @category1.id, 
                                    :medium_id => @medium1.id)
    @resources = [@resource1, @resource2, @resource3, @other_vendor_resource]
                                    
  end
  
  describe "for non-logged-in users" do
    
    describe "GET 'index'" do
      
      it "should not be successful" do
        get :index
        response.should_not be_success
      end
      
      it "should redirect to the login path" do
        get :index
        response.should redirect_to login_path
      end
    end
    
    describe "GET 'new'" do
      it "should not be successful" do
        get :new, :group => "Job"
        response.should_not be_success
      end
      
      it "should redirect to the login path" do
        get :new, :group => "Job"
        response.should redirect_to login_path
      end
    end
    
    
    describe "POST 'create'" do
      
      before(:each) do
        @good_attr = { :name => "Good Book", :category_id => @category1.id,
                       :medium_id => @medium1.id, :length_unit => "Page", :length => 244 }
      end
      
      it "should not add a new resource" do
        lambda do
          post :create, :vendor_id => @vendor2.id, :resource => @good_attr 
        end.should_not change(Resource, :count)
      end
      
      it "should redirect to the root path" do
        post :create, :vendor_id => @vendor2.id, :resource => @good_attr
        response.should redirect_to root_path 
      end
    end
  end
  
  
  describe "for logged_in non-vendors" do
    
    before(:each) do
      @non_vendoruser = Factory(:user, :name => "Non-vendor", :email => "nonvendor@example.com", 
                                       :country_id => @country.id)
      test_log_in(@non_vendoruser)
      test_vendor_cookie(@user)
    end
    
    describe "GET 'index'" do
      
      it "should not be successful" do
        get :index
        response.should_not be_success
      end
      
      it "should redirect to the root path" do
        get :index
        response.should redirect_to @non_vendoruser
      end
    end
    
    describe "GET 'new'" do
      it "should not be successful" do
        get :new, :group => "Job"
        response.should_not be_success
      end
      
      it "should redirect to the root path" do
        get :new, :group => "Job"
        response.should redirect_to @non_vendoruser
      end
    end
    
    describe "POST 'create'" do
      
      before(:each) do
        @good_attr = { :name => "Good Book", :category_id => @category1.id,
                       :medium_id => @medium1.id, :length_unit => "Page", :length => 244 }
      end
      
      it "should not add a new resource" do
        lambda do
          post :create, :vendor_id => @vendor2.id, :resource => @good_attr 
        end.should_not change(Resource, :count)
      end
      
      it "should redirect to the root path" do
        post :create, :vendor_id => @vendor2.id, :resource => @good_attr
        response.should redirect_to root_path 
      end
    end
  end
  
  describe "for logged-in vendors" do
    
    before(:each) do
      test_log_in(@user)
      test_vendor_cookie(@user)
    end
    
    describe "GET 'index'" do
      
      it "should be successful" do
        get :index
        response.should be_success
      end
      
      it "should have the correct title" do
        get :index
        response.should have_selector("title", :content => "Resources")  
      end
      
      it "should have a reference to the correct vendor" do
        get :index
        response.should have_selector(".h_tag", :content => @vendor2.name)
      end
      
      it "should not have a reference to the wrong vendor" do
        get :index
        response.should_not have_selector(".h_tag", :content => @vendor.name)
      end
      
      it "should have a resource-name reference for each element" do
        get :index
        @resources[0..2].each do |resource|
          response.should have_selector("td", :content => resource.name)
        end
      end
      
      it "should not include reference to resources from other vendors" do
        get :index
        response.should_not have_selector("td", :content => @other_vendor_resource.name)
      end
      
      it "should have a link to the resource show-page for each element" do
        get :index
        @resources[0..2].each do |resource|
          response.should have_selector("a", :href => resource_path(resource))
        end
      end
      
      it "should have a group reference for each element" do
        get :index
        @resources[0..2].each do |resource|
          response.should have_selector("td", 
                  :content => "#{resource.category.in_group}")
        end
      end
      
      it "should have a category reference for each element" do
        get :index
        @resources[0..2].each do |resource|
          response.should have_selector("td", 
                  :content => "#{resource.category.category}")
        end
      end
      
      it "should have a format reference for each element" do
        get :index
        @resources[0..2].each do |resource|
          response.should have_selector("td", 
                  :content => resource.medium.medium)
        end
      end
      
      it "should have a course-length reference for each element" do
        get :index
        @resources[0..2].each do |resource|
          response.should have_selector("td", :content => "24 hours")
        end
      end
      
      it "should have a delete option for resources that have never been scheduled" do
        pending "to be implemented in helper after scheduling has been added"
      end
      
      it "should have a 'hidden' reference for resources the vendor opts not to display" do
        
      end
      
      it "should successfully paginate the data" do
        30.times do
          @resources << Factory(:resource, :name => Factory.next(:name), 
                                :vendor_id => @vendor2.id, :medium_id => @medium1.id,
                                :category_id => @category1.id)
        end
        get :index
        response.should have_selector("div.pagination")
        response.should have_selector("span.disabled", :content => "Previous")
        response.should have_selector("a",  :href => "/resources/index?page=2",
                                            :content => "2")
        response.should have_selector("a",  :href => "/resources/index?page=2",
                                            :content => "Next")
      end
      
      it "should allow the user to filter by group" do
        pending "not implemented yet"
      end
      
      it "should allow the user to filter by category" do
        pending "not implemented yet"
      end
      
      it "should allow the user to filter by media type" do
        pending "not implemented yet"
      end
      
      it "should have an 'Add a new resource' link" do
        get :index
        response.should have_selector("a", :href => resource_group_path)
      end
    end

    describe "GET 'new'" do
      
      it "should be successful" do
        get :new, :group => "Job"
        response.should be_success
      end
      
      it "should have the right title" do
        get :new, :group => "Job"
        response.should have_selector("title", :content => "New resource")
      end
      
      it "should display the correct vendor name" do
        get :new, :group => "Job"
        response.should have_selector(".h_tag", :content => @vendor2.name)
      end
      
      it "should have a visible, editable text-box for the new resource name" do
        get :new, :group => "Job"
        response.should have_selector("input",  :name => "resource[name]",
                                                :content => "")
      end
      
      it "should have an empty category_id select-box" do
        get :new, :group => "Job"
        response.should have_selector("select", :name => "resource[category_id]",
                                                :content => "Please select")
      end
      
      it "should have the correct selection options for the category select box" do
        get :new, :group => "Job"
        @categories[0..2].each do |category|
          response.should have_selector("option", :content => category.category)
        end
      end
      
      it "should not have the wrong selection options for the category select box" do
        get :new, :group => "Job"
        response.should_not have_selector("option", :content => @category4.category)
      end
      
      it "should have an empty medium_id(= Format) select-box" do
        get :new, :group => "Job"
        response.should have_selector("select", :name => "resource[medium_id]",
                                                :content => "Please select")
      end
      
      it "should have the correct selection options for the format select box" do
        get :new, :group => "Job"
        @media[0..1].each do |medium|
          response.should have_selector("option", :content => medium.medium)
        end
      end
      
      it "should not have the wrong selection options for the format select box" do
        get :new, :group => "Job"
        response.should_not have_selector("option", :content => @medium3.medium)
      end
      
      it "should have a length_unit select-box, prefilled with 'hour'" do
        get :new, :group => "Job"
        response.should have_selector("option", :value => "Hour",
                                                :selected => "selected")
      end
      
      it "should have the correct selection options for the length_unit select box" do
        get :new, :group => "Job"
        response.should have_selector("option", :content => "Page")
      end
      
      it "should have a 'length' text-box, prefilled with 1" do
        get :new, :group => "Job"
        response.should have_selector("input",  :name => "resource[length]",
                                                :value => "1")
      end
      
      it "should have an empty 'description' text area" do
        get :new, :group => "Job"
        response.should have_selector("textarea",  :name => "resource[description]",
                                                   :content => "")
      end
      
      it "should have an empty 'webpage' text-box" do
        get :new, :group => "Job"
        response.should have_selector("input",  :name => "resource[webpage]",
                                                :content => "")
      end
      
      it "should have a Create button" do
        get :new, :group => "Job"
        response.should have_selector("input", :value => "Create")
      end
      
      it "should have a link to the new category form" do
        pending
      end
      
      it "should have a link to the new media (Format) form" do
        pending
      end
      
      it "should include a text area to add up to 10 related tags" do
        pending
      end
    end
    
    
    describe "POST 'create'" do
      
      before(:each) do
        @good_attr = { :name => "Good Book", :category_id => @category1.id,
                       :medium_id => @medium1.id, :length_unit => "Page", :length => 244
        }
        @bad_attr = { :name => "", :vendor_id => @vendor2.id, :category_id => @category1.id,
                      :medium_id => @medium1.id, :length_unit => "Century", :length => 4
        }
      end
      
      describe "success" do
        
        it "should create a new resource" do
          lambda do
            post :create, :vendor_id => @vendor2.id, :resource => @good_attr 
          end.should change(Resource, :count).by(1)
        end
        
        it "should be associated with the correct vendor" do
          post :create, :vendor_id => @vendor2.id, :resource => @good_attr 
          @resource = Resource.find(:last)
          @resource.vendor_id.should == @vendor2.id
        end
        
        it "should redirect to the 'show' page" do
          post :create, :vendor_id => @vendor2.id, :resource => @good_attr 
          @resource = Resource.find(:last)
          response.should redirect_to @resource 
        end
        
        it "should have a success message" do
          post :create, :vendor_id => @vendor2.id, :resource => @good_attr 
          flash[:success].should =~ /successfully created/
        end   
      end
      
      describe "failure" do
        
        it "should not create a new resource" do
          lambda do
            post :create, :vendor_id => @vendor2.id, :resource => @bad_attr 
          end.should_not change(Resource, :count)
        end
        
        it "should redisplay the 'new' page" do
          post :create, :vendor_id => @vendor2.id, :resource => @bad_attr 
          response.should render_template("new")
        end
        
        it "should have the right title" do
          post :create, :vendor_id => @vendor2.id, :resource => @bad_attr 
          response.should have_selector("title", :content => "New resource")
        end
        
        it "should have a failure message explaining the errors" do
          post :create, :vendor_id => @vendor2.id, :resource => @bad_attr 
          response.should have_selector("div#error_explanation", :content => "There were problems")     
        end
      end
    end
    
    
    describe "GET 'show'" do 
      
      it "should be successful" do
        get :show, :id => @resource1
        response.should be_success
      end
      
      it "should display the resource name" do
        get :show, :id => @resource1
        response.should have_selector("h1", :content => @resource1.name)
      end
      
      it "should have the right title" do
        get :show, :id => @resource1
        response.should have_selector("title", :content => @resource1.name)
      end
      
      it "should display the resource vendor" do
        get :show, :id => @resource1
        response.should have_selector(".two_column_left", :content => @vendor2.name.upcase)
      end
      
      it "should display the resource category and group" do
        get :show, :id => @resource1
        response.should have_selector(".two_column_left", 
              :content => "#{@resource1.category.in_group} - #{@resource1.category.category}")
      end
      
      it "should display the resource format" do
        get :show, :id => @resource1
        response.should have_selector(".two_column_left", :content => @resource1.medium.medium)
      end
      
      it "should display the resource length" do
        get :show, :id => @resource1
        response.should have_selector(".two_column_left", :content => "24 hours")
      end
      
      it "should display the 'description', if any" do
        get :show, :id => @resource2
        response.should have_selector(".description", :content => @resource2.description)
      end
      
      it "should encourage the user to add a description if the description is blank" do
        get :show, :id => @resource1
        response.should have_selector(".description", :content => "We strongly recommend")
      end
      
      it "should display a link to the resource webpage, if any" do
        get :show, :id => @resource2
        response.should have_selector("a", :href => "#{@resource2.webpage}", 
                                           :content => @resource2.webpage)
      end
      
      it "should open the webpage link in a new tab, if clicked" do
        get :show, :id => @resource2
        response.should have_selector("a", :href => "#{@resource2.webpage}", 
                                           :target => "_blank")
      end
      
      it "should not display 'More info' if there is no webpage listed" do
        get :show, :id => @resource1
        response.should_not have_selector("a", :href => "#{@resource1.webpage}")
        response.should_not have_selector("two_column_left", :content => "More info:")
      end
      
      it "should have an 'Edit' link" do
        get :show, :id => @resource1
        response.should have_selector("a", :href => edit_resource_path(@resource1))
      end
      
      it "should include a list of keywords associated with the resource" do
        pending "till keywords added"
      end
      
      it "should set the 'current_resource' cookie to the current resource.id" do
        pending "to be added"
      end
      
      it "should have a link to add a new resource for this vendor" do
        get :show, :id => @resource1
        response.should have_selector("a", :href => resource_group_path,
                                            :content => "Add a new resource")
      end
      
      it "should not be possible to duplicate this resource to another vendor, for single-vendor users" do
        get :show, :id => @resource1
        response.should_not have_selector("a", :href => "/duplicate_resource_to_vendor",
                                           :content => "another of your vendors")
      end
      
      it "should display the number of reviews" do
        pending "awaiting reviews to be added"
      end
      
      it "should display the average review score" do
        pending "awaiting reviews to be added"
      end
      
      it "should display any public reviews" do
        pending "awaiting reviews to be added"
      end
      
      it "should show whether reviews are shown in the public display" do
        pending "awaiting reviews to be added"
      end
      
      it "should have a link to the reviews page" do
        pending "awaiting reviews to be added"
      end
      
      it "should show the number of tickets offered" do
        pending "awaiting tickets to be added"
      end
      
      it "should show the number of tickets 'purchased'" do
        pending "awaiting tickets to be added"
      end
      
      it "should show the number of tickets currently outstanding" do
        pending "awaiting tickets to be added"
      end
      
      it "should have a link to the tickets page" do
        pending "awaiting tickets to be added"
      end
      
      it "should have a link to the 'schedule' page for this resource" do
        pending "awaiting schedule to be added"
      end
   
      it "should warn that no records will be displayed for an unverified vendor" do
        get :show, :id => @other_vendor_resource
        response.should have_selector(".two_column_left", :content => "this resource will not be seen")
      end
      
      it "should not display the verification warning if the vendor has been verified" do
        get :show, :id => @resource1
        response.should_not have_selector(".two_column_left", :content => "this resource will not be seen")
      end
      
      it "should show that hidden resources are hidden" do
        pending "to be added"
      end
      
      it "should show that displayed resources are displayed" do
        pending "to be added"
      end
      
      describe "when the user has more than one vendor" do
        
        before(:each) do
          @vendor3 = Factory(:vendor, :name => "Vendor3", :country_id => @country.id)
          @representation3 = Factory(:representation, :user_id => @user.id, :vendor_id => @vendor3.id) 
          @resource4 = Factory(:resource, :name => "Resource2", :vendor_id => @vendor3.id, 
                                        :category_id => @category1.id, :webpage => "webpage@example.com",
                                        :medium_id => @medium1.id, :description => "It's a")
        end
        
        it "should be possible to duplicate this resource to another associated vendor" do
          get :show, :id => @resource1
          response.should have_selector("a", :href => "/duplicate_resource_to_vendor",
                                           :content => "another of your vendors")
        end
        
        it "should not be possible to dupicate this resource to a vendor, if all already have the resource" do
          get :show, :id => @resource2
          response.should_not have_selector("a", :href => "/duplicate_resource_to_vendor",
                                               :content => "another of your vendors")
        end
      end        
    end
  end
end
