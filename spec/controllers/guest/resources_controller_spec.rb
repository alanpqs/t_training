require 'spec_helper'

describe Guest::ResourcesController do

  render_views
  
   before(:each) do
    @region = Factory(:region)
    @country = Factory(:country, :region_id => @region.id)
    @vendor_user = Factory(:user, :country_id => @country.id, :vendor => true)  
    @verified_vendor = Factory(:vendor, :name => "V Vendor", :country_id => @country.id, :verified => true)   
    @representation_OK = Factory(:representation, :user_id => @vendor_user.id, 
                                 :vendor_id => @verified_vendor.id) 
    @category1 = Factory(:category, :user_id => @vendor_user.id, :authorized => true)
    @category2 = Factory(:category, :user_id => @vendor_user.id, :category => "HS", :authorized => true)
    @category3 = Factory(:category, :user_id => @vendor_user.id, :category => "HT", :authorized => true)
    @scheduled_medium = Factory(:medium, :user_id => @vendor_user.id, :authorized => true, :scheduled => true)
    @resource_medium = Factory(:medium, :medium => "Fgh", :user_id => @vendor_user.id, :authorized => true)
    @scheduled_resource = Factory(:resource, :vendor_id => @verified_vendor.id, :category_id => @category1.id, 
                                    :medium_id => @scheduled_medium.id)
    @unscheduled_resource = Factory(:resource, :name => "Unscheduled 1", :vendor_id => @verified_vendor.id, 
                                    :category_id => @category1.id, :webpage => "webpage@example.com",
                                    :medium_id => @resource_medium.id, :description => "It's a")
    @resources = [@scheduled_resource, @unscheduled_resource]
                                    
  end
  
  describe "GET 'index'" do
    
    describe "before a search has been made" do
      
      it "should be successful" do
        get :index
        response.should be_success
      end
    
      it "should have the right title" do
        get :index
        response.should have_selector("title", :content => "Find a training resource")
      end
    
      it "should list scheduled resource names" do
         get :index
         response.should have_selector(".notes", :content => "Resource")
      end
    
      it "should list unscheduled resource names" do
         get :index
         response.should have_selector(".notes", :content => "Unscheduled 1")
      end
      
      it "should list the resource vendors" do
        get :index
        response.should have_selector(".notes", :content => "V Vendor")
      end
    
      it "should not list resources from unverified vendors" do
        @non_verified_vendor = Factory(:vendor, :name => "X Vendor", :country_id => @country.id)
        @representation_X = Factory(:representation, :user_id => @vendor_user.id, 
                                 :vendor_id => @non_verified_vendor.id)
        @non_verified_resource = Factory(:resource, :name => "Not verified", 
                                    :vendor_id => @non_verified_vendor.id, 
                                    :category_id => @category1.id, :webpage => "webpage@example.com",
                                    :medium_id => @resource_medium.id, :description => "It's a")
        get :index
        response.should_not have_selector(".notes", :content => "X Vendor")
      end
    
      it "should not list resources from inactive vendors" do
        @inactive_vendor = Factory(:vendor, :name => "IA Vendor", :country_id => @country.id, 
                               :verified => true, :inactive => true)
        @representation_IA = Factory(:representation, :user_id => @vendor_user.id, 
                                 :vendor_id => @inactive_vendor.id) 
        @inactive_resource = Factory(:resource, :name => "No longer", 
                                    :vendor_id => @inactive_vendor.id, 
                                    :category_id => @category1.id, :webpage => "webpage@example.com",
                                    :medium_id => @resource_medium.id, :description => "It's a")          
        get :index
        response.should_not have_selector(".notes", :content => "No longer")
      end
      
      it "should not include any resources that the vendor has hidden" do
        @hidden_resource = Factory(:resource, :name => "Hidden", :vendor_id => @verified_vendor.id, 
                                    :category_id => @category1.id, :webpage => "webpage@example.com",
                                    :medium_id => @resource_medium.id, :hidden => true)
        get :index
        response.should_not have_selector(".notes", :content => "Hidden")
      end
      
      it "should indicate which resources can be ordered now" do
        pending "problem testing image when it exists in rubric"
        #@event_item = Factory(:item, :resource_id => @scheduled_resource.id)
        #@resource_item = Factory(:item, :resource_id => @unscheduled_resource.id)
        #get :index
        #@resources.each do |resource|
        #  response.should have_selector("img", :alt => "Tick_octagon")
        #end
      end
      
      it "should indicate which resources cannot be ordered now" do
        pending "problem testing image when it exists in rubric"
        #get :index
        #@resources.each do |resource|
        #  response.should_not have_selector("img", :alt => "Tick_octagon")
        #end
      end
      
      it "should list the vendor location" do
        get :index
        response.should have_selector(".notes", :content => "London, ABC")
      end
  
      it "should include the vendor name" do
        get :index
        response.should have_selector(".notes", :content => @verified_vendor.name)
      end
      
      it "should include the resource format" do
        get :index
        response.should have_selector(".notes", :content => @scheduled_medium.medium)
      end
      
      it "should include the average client rating" do
        pending "till ratings have been added"
      end
      
      it "should have a link to the resource 'show' form" do
        get :index
        @resources.each do |resource|
          response.should have_selector("a", :href => guest_resource_path(resource),
                                             :content => resource.name)
        end
      end
    
      it "should explain the advantages of searching as a signed-up member" do
        get :index
        response.should have_selector(".rounded_right", :content => "exclusively for logged-in members")
      end
    
      it "should have a link to the signup form" do
        get :index
        response.should have_selector("a", :href => signup_path,
                                           :content => "Free sign-up here")
      end
    
      it "should have a search box" do
        get :index
        response.should have_selector("input", :value => "Search")
      end
      
      it "should have a link to the 'effective searches' page" do
        pending
      end
      
      it "should have page guidance" do
        get :index
        response.should have_selector("h5", :content => "Guidance for this page")
      end
      
      it "should paginate the entries to allow display only 20 resources per page" do
        20.times do
          @resources << Factory(:resource, :name => Factory.next(:name), :vendor_id => @verified_vendor.id, 
                                :category_id => @category1.id, :webpage => "webpage@example.com",
                                :medium_id => @resource_medium.id)
        end
        get :index
        response.should have_selector("div.pagination")
        response.should have_selector("span.disabled", :content => "Previous")
        response.should have_selector("a",    :href => "/guest/resources?page=2",
                                              :content => "2")
        response.should have_selector("a",    :href => "/guest/resources?page=2",
                                              :content => "Next")
      end
      
      it "should whether tickets are currently available for the resource" do
        pending
      end
        
      describe "after a search has been made" do
        
        it "should correctly filter the resources that match the search parameters" do
          pending "till search facility added"
        end
    
        it "should not list items that have been filtered out by the search" do
          pending "till search facility added"
        end
        
        it "should not list resources from unverified vendors" do
          pending "till search facility added"
        end
    
        it "should not include any resources that the vendor has hidden" do
          pending "till search facility added"
        end
        
        it "should not list resources from inactive vendors" do
          pending "till search facility added"
        end
        
      end
        
    end 
    
  end

  describe "GET 'show'" do
    pending
    #it "should be successful" do
    #  get :show
    #  response.should be_success
    #end
  end

end
