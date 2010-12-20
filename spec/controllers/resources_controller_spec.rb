require 'spec_helper'

describe ResourcesController do

  render_views
  
  before(:each) do
    @region = Factory(:region)
    @country = Factory(:country, :region_id => @region.id)
    @user = Factory(:user, :country_id => @country.id, :vendor => true)
    @vendor = Factory(:vendor, :country_id => @country.id)
    @vendor2 = Factory(:vendor, :name => "Vendor2", :country_id => @country.id)
    @representation = Factory(:representation, :user_id => @user.id, :vendor_id => @vendor2.id) 
    @category1 = Factory(:category, :user_id => @user.id, :authorized => true)
    @category2 = Factory(:category, :user_id => @user.id, :category => "HS", :authorized => true)
    @category3 = Factory(:category, :user_id => @user.id, :category => "HT", :authorized => true)
    
    @category4 = Factory(:category, :user_id => @user.id, :category => "HU", :target => "Fun", :authorized => true )
    @categories = [@category1, @category2, @category3, @category4]
    @medium1 = Factory(:medium, :user_id => @user.id, :authorized => true)
    @medium2 = Factory(:medium, :medium => "Fgh", :user_id => @user.id, :authorized => true)
    @medium3 = Factory(:medium, :medium => "Jkl", :user_id => @user.id)
    @media = [@medium1, @medium2, @medium3]
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
      
      it "should have an 'Add a new resource' link" do
        get :index
        response.should have_selector("a", :href => resource_group_path)
      end
    end

    describe "GET 'new'" do
      
      it "should be successful" do
        get 'new', :group => "Job"
        response.should be_success
      end
      
      it "should have the right title" do
        get 'new', :group => "Job"
        response.should have_selector("title", :content => "New resource")
      end
      
      it "should display the correct vendor name" do
        get 'new', :group => "Job"
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
  end

end
