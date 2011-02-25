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
    @medium1 = Factory(:medium, :user_id => @user.id, :authorized => true, :scheduled => true)
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
    @good_attr = { :name => "Good name", :category_id => @category2.id, :medium_id => @medium2.id, 
                                          :feature_list => "hot, sticky"}
                                    
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
    
    describe "GET 'show'" do
      
      it "should not be successful" do
        get :show, :id => @resource1
        response.should_not be_success
      end
      
      it "should redirect to the login page" do
        get :show, :id => @resource1
        response.should redirect_to login_path
      end
    end
    
    describe "GET 'edit'" do
      
      it "should not be successful" do
        get :edit, :id => @resource1
        response.should_not be_success
      end
      
      it "should redirect to the login page" do
        get :edit, :id => @resource1
        response.should redirect_to login_path
      end
    end
    
    describe "PUT 'update'" do
      
      it "should not change the resource attributes" do
        put :update, :id => @resource1, :resource => @good_attr
        @resource1.reload
        @resource1.name.should_not == "Good name"
      end
      
      it "should redirect to the root path" do
        put :update, :id => @resource1, :resource => @good_attr
        response.should redirect_to root_path
      end
    end
    
    describe "DELETE 'destroy'" do
      
      it "should not delete the resource" do
        original_count = Resource.count(:all)
        delete :destroy, :id => @resource1
        new_count = Resource.count(:all)
        new_count.should == original_count
      end
    end
    
    it "should redirect to the login path" do
      delete :destroy, :id => @resource1
      response.should redirect_to login_path
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
      
      it "should redirect to the user home page" do
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
    
    describe "GET 'show'" do
      
      it "should not be successful" do
        get :show, :id => @resource1
        response.should_not be_success
      end
      
      it "should redirect to the login page" do
        get :show, :id => @resource1
        response.should redirect_to @non_vendoruser
      end
      
      it "should display a warning message" do
        get :show, :id => @resource1
        flash[:error].should =~ /an area that does not belong to you/
      end

    end
    
    describe "GET 'edit'" do
      
      it "should not be successful" do
        get :edit, :id => @resource1
        response.should_not be_success
      end
      
      it "should redirect to the login page" do
        get :edit, :id => @resource1
        response.should redirect_to @non_vendoruser
      end
    end
    
    describe "PUT 'update'" do
      
      it "should not change the resource attributes" do
        put :update, :id => @resource1, :resource => @good_attr
        @resource1.reload
        @resource1.name.should_not == "Good name"
      end
      
      it "should redirect to the login page" do
        put :update, :id => @resource1, :resource => @good_attr
        response.should redirect_to @non_vendoruser
      end
    end
    
    describe "DELETE 'destroy'" do
      
      it "should not delete the resource" do
        original_count = Resource.count(:all)
        delete :destroy, :id => @resource1
        new_count = Resource.count(:all)
        new_count.should == original_count
      end
    end
    
    it "should redirect to the login path" do
      delete :destroy, :id => @resource1
      response.should redirect_to @non_vendoruser
    end
    
    it "should display a warning message" do
      delete :destroy, :id => @resource1
      flash[:error].should =~ /an area that does not belong to you/
    end

  end
  
  describe "for logged-in vendor-users, associated with the vendor company" do
    
    before(:each) do
      @tagged_resource1 = Factory(:resource, :name => "Tagged1", :vendor_id => @vendor2.id, 
                                    :category_id => @category1.id, 
                                    :medium_id => @medium1.id,
                                    :feature_list => "good, nice, fun")
      @tagged_resource2 = Factory(:resource, :name => "Tagged2", :vendor_id => @vendor2.id, 
                                    :category_id => @category1.id, 
                                    :medium_id => @medium1.id,
                                    :feature_list => "brave, strong")
      @tagged_noncat_resource = Factory(:resource, :name => "OtherCatTagged", :vendor_id => @vendor2.id, 
                                    :category_id => @category2.id, 
                                    :medium_id => @medium1.id,
                                    :feature_list => "sad, wrong")                              
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
        @resources[0..1].each do |resource|
          response.should have_selector("td", :content => resource.name)
        end
      end
      
      it "should not include reference to resources from other vendors" do
        get :index
        response.should_not have_selector("td", :content => @other_vendor_resource.name)
      end
      
      it "should have a link to the resource show-page for each element" do
        get :index
        @resources[0..1].each do |resource|
          response.should have_selector("a", :href => resource_path(resource))
        end
      end
      
      it "should have a group reference for each element" do
        get :index
        @resources[0..1].each do |resource|
          response.should have_selector("td", 
                  :content => "#{resource.category.in_group}")
        end
      end
      
      it "should have a category reference for each element" do
        get :index
        @resources[0..1].each do |resource|
          response.should have_selector("td", 
                  :content => "#{resource.category.category}")
        end
      end
      
      it "should have a format reference for each element" do
        get :index
        @resources[0..1].each do |resource|
          response.should have_selector("td", 
                  :content => resource.medium.medium)
        end
      end
      
      it "should have a course-length reference for each element" do
        get :index
        @resources[0..1].each do |resource|
          response.should have_selector("td", :content => "24 hours")
        end
      end
      
      it "should have a delete option for resources that have never been scheduled" do
        pending "to be implemented in helper after scheduling has been added"
      end
      
      it "should have a 'hidden' reference for resources the vendor opts not to display" do
        
      end
      
      it "should successfully paginate the data" do
        31.times do
          @resources << Factory(:resource, :name => Factory.next(:name), 
                                :vendor_id => @vendor2.id, :medium_id => @medium1.id,
                                :category_id => @category1.id)
        end
        get :index
        response.should have_selector("div.pagination")
        response.should have_selector("span.disabled", :content => "Previous")
        response.should have_selector("a",  :href => "/resources?page=2",
                                            :content => "2")
        response.should have_selector("a",  :href => "/resources?page=2",
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
        get :new, :group => "Job"
        response.should have_selector("a",  :href => new_business_category_path)    
      end
      
      it "should have a link to the new media (Format) form" do
        get :new, :group => "Job"
        response.should have_selector("a",  :href => new_business_medium_path)     
      end
      
      it "should include a text area to add up to 15 related tags" do
        get :new, :group => "Job"
        response.should have_selector("input",  :name => "resource[feature_list]",
                                                :value => "")
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
      
      it "should include a list of associated keywords" do
        get :show, :id => @tagged_resource1
        response.should have_selector("div#features", :content => "fun")
      end
      
      it "should not include non-associated keywords" do
        get :show, :id => @tagged_resource1
        response.should_not have_selector("div#features", :content => "brave, strong")
      end
      
      it "should set the 'current_resource' cookie to the current resource.id" do
        get :show, :id => @resource1
        response.cookies["resource_id"].should == @resource1.id.to_s
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
        @other_representation = Factory(:representation, :user_id => @user.id,
                    :vendor_id => @vendor.id)
        get :show, :id => @other_vendor_resource
        response.should have_selector(".two_column_left", :content => "this resource will not be seen")
      end
      
      it "should not display the verification warning if the vendor has been verified" do
        pending "differs depending on whether scheduled or unscheduled event"
        
        #get :show, :id => @resource1
        #response.should_not have_selector(".two_column_left", :content => "this resource will not be seen")
      end
      
      it "should show not display a hidden notice unless the resource is marked hidden" do
        get :show, :id => @resource1
        response.should_not have_selector("h4", 
                  :content => "This resource is currently hidden from public view.")
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
      
      describe "when an event-type resource has been archived" do
        
        before(:each) do
          @hidden_event = Factory(:resource, :name => "Hidden event", :vendor_id => @vendor2.id, 
                                    :category_id => @category1.id, :webpage => "hidden@example.com",
                                    :medium_id => @medium1.id, :hidden => true)       
        end
        
        it "should display a prominent 'hidden resource' label" do
          get :show, :id => @hidden_event
          response.should have_selector("h4", 
                  :content => "This resource is currently hidden from public view.")
        end
          
        it "should display an 'archived' notice" do
          get :show, :id => @hidden_event
          response.should have_selector(".cloud", 
                  :content => "RESOURCE NOW ARCHIVED")
        end
        
        it "should not display an 'In progress' label" do
          get :show, :id => @hidden_event
          response.should_not have_selector(".loud", :content => "In progress")
        end
        
        it "should not display a 'Next scheduled' label" do
          get :show, :id => @hidden_event
          response.should_not have_selector(".loud", :content => "Next scheduled")
        end
        
        it "should not display an 'Add a new event' link" do
          get :show, :id => @hidden_event
          response.should_not have_selector("a", :href => new_resource_item_path(@resource1),
                                                 :content => "Add a new event")
        end
        
        it "should warn that no new events may be added" do
          get :show, :id => @hidden_event
          response.should have_selector(".loud", :content => "No new events may be added")
        end
        
        it "should warn that planned events are no longer displayed" do
          get :show, :id => @hidden_event
          response.should have_selector(".loud", :content => "Planned events are no longer displayed")
        end
        
        it "should not display an 'All planned events' link" do
          get :show, :id => @hidden_event
          response.should_not have_selector("a", :href => resource_items_path(@resource1),
                                                 :content => "All planned events")
        end
        
        it "should continue to show current events, and edit/modify current and future events" do
          pending "should it do this?"
        end
            
      end
 
      describe "when a resource of the non-event type has been archived" do
          
        before(:each) do
          @hidden_resource = Factory(:resource, :name => "Hidden resource", :vendor_id => @vendor2.id, 
                                    :category_id => @category1.id, :webpage => "hide@example.com",
                                    :medium_id => @medium2.id, :hidden => true)       
        end
        
        it "should display a prominent 'hidden resource' label" do
          get :show, :id => @hidden_resource
          response.should have_selector("h4", 
                  :content => "This resource is currently hidden from public view.")
        end
          
        it "should not display an 'archived' notice" do
          get :show, :id => @hidden_resource
          response.should_not have_selector(".cloud", 
                  :content => "RESOURCE NOW ARCHIVED")
        end
        
        describe "and pricing details were never set" do
        
          it "should explain that pricing was not set" do
            get :show, :id => @hidden_resource
            response.should have_selector(".loud", :content => "Pricing details not set before archiving")
          end
          
        end
        
        describe "and pricing was set before archiving" do
          
          before(:each) do
            @price_for_hidden_resource = Factory(:item, :resource_id => @hidden_resource.id,
                                  :finish => nil)
          end
          
          it "should give pricing details before archiving" do
            get :show, :id => @hidden_resource
            response.should have_selector(".loud", :content => "Details when archived")
          end   
        end
      end
      
      describe "when the resource has not been archived" do
        
        describe "when the resource is of the event type" do  #has medium set to scheduled
      
          describe "when there are no planned or past events" do
        
            it "should display a 'NONE PLANNED' label" do
              get :show, :id => @resource1
              response.should have_selector(".loud", :content => "NONE PLANNED")
            end
        
            it "should not display an 'In progress' label" do
              get :show, :id => @resource1
              response.should_not have_selector(".loud", :content => "In progress")
            end
        
            it "should not display a 'Next scheduled' label" do
              get :show, :id => @resource1
              response.should_not have_selector(".loud", :content => "Next scheduled")
            end
        
            it "should not display a table for current or next scheduled events" do
              get :show, :id => @resource1
              response.should_not have_selector("th", :content => "Ref no")
            end
        
            it "should display an 'Add a new event' link" do
              get :show, :id => @resource1
              response.should have_selector("a", :href => new_resource_item_path(@resource1),
                                                 :content => "Add a new event")
            end
        
            it "should not display an 'All planned events' link" do
              get :show, :id => @resource1
              response.should_not have_selector("a", :href => resource_items_path(@resource1),
                                                 :content => "All planned events")
            end
        
            it "should not display a 'Previous events' link" do
              get :show, :id => @resource1
              response.should_not have_selector("a", :href => resource_past_events_path(@resource1),
                                                 :content => "Previous events")
            end
          end
      
          describe "when there are current events but no future or past events" do
        
            before(:each) do
              @item = Factory(:item, :start => Time.now - 2.days, :finish => Time.now + 2.days, 
                                   :resource_id => @resource1.id)
            end
        
            it "should not display a 'NONE PLANNED' label" do
              get :show, :id => @resource1
              response.should_not have_selector(".loud", :content => "NONE PLANNED")
            end
        
            it "should display an 'In progress' label" do
              get :show, :id => @resource1
              response.should have_selector(".loud", :content => "In progress")
            end
        
            it "should not display a 'Next scheduled' label" do
              get :show, :id => @resource1
              response.should_not have_selector(".loud", :content => "Next scheduled")
            end
        
            it "should display a table for current events" do
              get :show, :id => @resource1
              response.should have_selector("th", :content => "Ref #")
            end
        
            it "should display an 'Add a new event' link" do
              get :show, :id => @resource1
              response.should have_selector("a", :href => new_resource_item_path(@resource1),
                                                 :content => "Add a new event")
            end
        
            it "should not display an 'All planned events' link" do
              get :show, :id => @resource1
              response.should_not have_selector("a", :href => resource_items_path(@resource1),
                                                 :content => "All planned events")
            end
        
            it "should not display a 'Previous events' link" do
              get :show, :id => @resource1
              response.should_not have_selector("a", :href => resource_past_events_path(@resource1),
                                                 :content => "Previous events")
            end
          end
      
          describe "when there are current and future events but no past events" do
            pending
          end
      
          describe "when there are current and past events but no future events" do
            pending
          end
      
          describe "when there are current, past and future events" do
            pending
          end
      
          describe "when there are past events but no current or future events" do
        
          end
      
          describe "when there are future events but no current or past events" do
            pending
          end
      
          describe "when there are past and future events but no current events" do
            pending
          end
        end
      
        describe "when the resource is not a scheduled event" do      #i.e. medium not set to scheduled
        
          before(:each) do
            @unsched_resource = Factory(:resource, :name => "Unscheduled", :vendor_id => @vendor2.id, 
                                    :category_id => @category1.id, :webpage => "unsched@example.com",
                                    :medium_id => @medium3.id, :description => "Unscheduled")
          
          end
        
          describe "when the vendor has been verified" do
        
            it "should not have a 'Next scheduled' label" do
              pending "till non-events are added"
            end 
          end
        
          describe "when the author has not been verified" do
          
            it "should remind the user to verify the vendor account" do
              pending "till non-events are added"
            end
          end
        end
      end        
    end
    
    describe "GET 'edit'" do
      
      it "should be successful" do
        get :edit, :id => @resource1
        response.should be_success
      end
      
      it "should have the right title" do
        get :edit, :id => @resource1
        response.should have_selector("title", :content => "Edit resource")
      end
      
      it "should display the correct vendor name" do
         get :edit, :id => @resource1
        response.should have_selector(".h_tag", :content => @vendor2.name)
      end
      
      it "should have a visible, editable text-box for the resource name" do
         get :edit, :id => @resource1
        response.should have_selector("input",  :name => "resource[name]",
                                                :value => @resource1.name)
      end
      
      it "should have a select field for Categories with the correct Category displayed" do
        get :edit, :id => @resource1
        response.should have_selector("option", :value => @resource1.category_id.to_s,
                                                :selected => "selected",
                                                :content => @resource1.category.category)
      end
      
      it "should have the correct selection options for the category select box" do
        get :edit, :id => @resource1
        @categories[0..2].each do |category|
          response.should have_selector("option", :content => category.category)
        end
      end
      
      it "should not have the wrong selection options for the category select box" do
        get :edit, :id => @resource1
        response.should_not have_selector("option", :content => @category4.category)
      end
      
      it "should have a select field for Media with the correct Medium displayed" do
        get :edit, :id => @resource1
        response.should have_selector("option", :value => @resource1.medium_id.to_s,
                                                :selected => "selected",
                                                :content => @resource1.medium.medium)
      end
      
      it "should have the correct selection options for the Format (=Medium) select box" do
        get :edit, :id => @resource1
        @media[0..1].each do |medium|
          response.should have_selector("option", :content => medium.medium)
        end
      end
      
      it "should not have the wrong selection options for the Format select box" do
        get :edit, :id => @resource1
        response.should_not have_selector("option", :content => @medium3.medium)
      end
      
      it "should have the correct length_unit in a select-box" do
        get :edit, :id => @resource1
        response.should have_selector("option", :value => @resource1.length_unit,
                                                :selected => "selected",
                                                :content => @resource1.length_unit)
      end
      
      it "should have the correct selection options for the length_unit select box" do
        get :edit, :id => @resource1
        response.should have_selector("option", :content => "Page")
      end
      
      it "should have the correct Length in a text-box" do
        get :edit, :id => @resource1
        response.should have_selector("input",  :name => "resource[length]",
                                                :value => @resource1.length.to_s)
      end
      
      it "should have the correct Description in a text area" do
        get :edit, :id => @resource1
        response.should have_selector("textarea",  :name => "resource[description]",
                                                   :content => @resource1.description)
      end
      
      it "should have the correct Webpage reference in a text-box" do
        get :edit, :id => @resource1
        response.should have_selector("input",  :name => "resource[webpage]",
                                                :content => @resource1.webpage)
      end
      
      it "should have a 'Confirm changes' button" do
        get :edit, :id => @resource1
        response.should have_selector("input", :value => "Confirm changes")
      end
      
      it "should have a link to the new category form" do
        get :edit, :id => @resource1
        response.should have_selector("a",  :href => new_business_category_path)    
      end
      
      it "should have a link to the new media (Format) form" do
        get :edit, :id => @resource1
        response.should have_selector("a",  :href => new_business_medium_path)                 
      end
      
      it "should include a text area to add up to 15 related tags" do
        get :edit, :id => @tagged_resource1
        response.should have_selector("input", :name => "resource[feature_list]")
        # not fully tested - the content sort-order varies
      end
      
      it "should not include non-associated tags" do
        get :edit, :id => @tagged_resource1
        response.should_not have_selector("input", :name => "resource[feature_list]",
                                               :value => "strong, brave")
      end  
    end
    
    describe "PUT 'update'" do
      
      before(:each) do
        @flist_resource = Factory(:resource, :name => "Flist", :vendor_id => @vendor2.id, 
                                    :category_id => @category2.id, :webpage => "flist@example.com",
                                    :medium_id => @medium2.id, :description => "flist",
                                    :feature_list => "One, Two")
        #@good_attr = { :name => "Good name", :category_id => @category2.id, :medium_id => @medium2, 
        #               :feature_list => "hot, sticky"}
        @bad_attr = { :name => "" }
        @bad_attr_features = { :feature_list => "z, y, x, w, v, u, t, s, r, q, p, o, n, m, l, k" }
      end
      
      describe "success" do
      
        it "should update the resource attributes" do
          put :update, :id => @resource1, :resource => @good_attr
          resource = assigns(:resource)
          @resource1.reload
          @resource1.name.should == resource.name
          @resource1.category_id.should == resource.category_id
        end
        
        it "should remove any tags that have been edited out" do
          put :update, :id => @flist_resource, :resource => @good_attr
          resource = assigns(:resource)
          @flist_resource.reload
          @flist_resource.feature_list.should_not == "One, Two"
        end
        
        it "should redirect to the 'Show' page" do
          put :update, :id => @resource1, :resource => @good_attr
          response.should redirect_to resource_path(@resource1)
        end
        
        it "should display a success message" do
          put :update, :id => @resource1, :resource => @good_attr
          flash[:success].should =~ /Your resource was successfully updated/
        end
        
      end
      
      describe "failure" do
        
        it "should not update the resource attributes" do
          put :update, :id => @resource1, :resource => @bad_attr
          resource = assigns(:resource)
          @resource1.reload
          @resource1.name.should_not == resource.name
        end
        
        it "should not accept an overlong tag string" do
          put :update, :id => @flist_resource, :resource => @bad_attr_features
          resource = assigns(:resource)
          @flist_resource.reload
          @flist_resource.feature_list.should_not == resource.feature_list
        end
        
        it "should render the 'Edit' page" do
          put :update, :id => @resource1, :resource => @bad_attr
          response.should render_template("edit")
        end
          
        it "should display an appropriate error message" do
          put :update, :id => @resource1, :resource => @bad_attr
          response.should have_selector("div#error_explanation", :content => "There were problems")
        end
        
        it "should have the right title" do
          put :update, :id => @resource1, :resource => @bad_attr
          response.should have_selector("title", :content => "Edit resource") 
        end
      end
      
    end
    
    describe "DELETE 'destroy'" do
      
      before(:each) do
        @deletable_resource = Factory(:resource, :name => "Deletable", :vendor_id => @vendor2.id, 
                                     :category_id => @category1.id, :medium_id => @medium1.id)
      end
      
      describe "when not associated with a schedule" do
      
        describe "success" do
        
          it "should delete the resource" do
            original_count = Resource.count(:all)
            delete :destroy, :id => @deletable_resource
            new_count = Resource.count(:all)
            new_count.should == original_count - 1
          end
          
          it "should redirect to the index page" do
            @vendor2 = Vendor.find(@resource1.vendor_id)
            delete :destroy, :id => @resource1
            response.should redirect_to vendor_resources_path(@vendor2)
          end
          
          it "should have a success message, showing which resource has been deleted" do
            delete :destroy, :id => @resource1
            flash[:success].should == "'#{@resource1.name}' deleted."
          end
        end   
      end
      
      describe "when associated with a schedule" do
        
        it "should not delete the resource" do
          pending "until schedule is added"
        end
        
        it "should re-display the index page" do
          pending "until schedule is added"
        end
        
        it "should display an error message" do
          pending "until schedule is added"
        end
      end
      
    end
  end
  
  describe "for logged in vendor-users, not associated with the vendor company" do
    
    before(:each) do
      @wrong_user = Factory(:user, :email => "wrong_user@example.com", :country_id => @country.id, 
                                   :vendor => true)
      @vendor4 = Factory(:vendor, :name => "Vendor4", :country_id => @country.id)
      @representation4 = Factory(:representation, :user_id => @wrong_user.id, :vendor_id => @vendor4.id) 
      @resource5 = Factory(:resource, :name => "Resource5", :vendor_id => @vendor4.id, 
                                        :category_id => @category1.id, :webpage => "resource5@example.com",
                                        :medium_id => @medium1.id, :description => "This is a")
      test_log_in(@wrong_user)
      test_vendor_cookie(@wrong_user)
    end
    
    describe "GET 'show'" do 
      
      it "should not be successful" do
        get :show, :id => @resource1
        response.should_not be_success
      end
      
      it "should redirect to the business home path" do
        get :show, :id => @resource1
        response.should redirect_to business_home_path
      end
      
      it "should display an error message" do
        get :show, :id => @resource1
        flash[:error].should =~ /an area that does not belong to you/
      end
    end
    
    describe "GET 'edit'" do
      
      it "should not be successful" do
        get :edit, :id => @resource1
        response.should_not be_success
      end
      
      it "should redirect to the business home path" do
        get :edit, :id => @resource1
        response.should redirect_to business_home_path
      end
      
      it "should display an error message" do
        get :edit, :id => @resource1
        flash[:error].should =~ /an area that does not belong to you/
      end
    end
    
    describe "PUT 'update'" do
      
      it "should not change the resource attributes" do
        put :update, :id => @resource1, :resource => @good_attr
        @resource1.reload
        @resource1.name.should_not == "Good name"
      end
      
      it "should redirect to the business home path" do
        put :update, :id => @resource1, :resource => @good_attr
        response.should redirect_to business_home_path
      end
      
      it "should display an error message" do
        put :update, :id => @resource1, :resource => @good_attr
        flash[:error].should =~ /an area that does not belong to you/
      end
    end
    
    describe "DELETE 'destroy'" do
      before(:each) do
        @non_deletable_resource = Factory(:resource, :name => "Deletable", :vendor_id => @vendor2.id, 
                                     :category_id => @category1.id, :medium_id => @medium1.id)
      end
      
      it "should not delete the resource" do
        original_count = Resource.count(:all)
        delete :destroy, :id => @non_deletable_resource
        new_count = Resource.count(:all)
        original_count.should == new_count
      end
      
      it "should redirect to the business home path" do
        delete :destroy, :id => @non_deletable_resource
        response.should redirect_to business_home_path
      end
      
      it "should display an error message" do
        delete :destroy, :id => @non_deletable_resource
        flash[:error].should =~ /an area that does not belong to you/
      end
    end
  end
end
