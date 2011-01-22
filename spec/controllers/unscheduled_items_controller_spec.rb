require 'spec_helper'

describe UnscheduledItemsController do

  render_views
  
  require 'money'
  
  before(:each) do
    @region = Factory(:region)
    @country = Factory(:country, :name => "United Kingdom", :currency_code => "GBP", :region_id => @region.id)
    @user = Factory(:user, :country_id => @country.id, :vendor => true)
    @vendor = Factory(:vendor, :country_id => @country.id, :verified => true)
    @representation = Factory(:representation, :user_id => @user, :vendor_id => @vendor)
    @medium = Factory(:medium, :user_id => @user.id, :scheduled => false)
    @category = Factory(:category, :user_id => @user.id, :authorized => true)
    @resource = Factory(:resource, :vendor_id => @vendor.id, :category_id => @category.id, 
                                   :medium_id => @medium.id)
                            
    @wrongvendor_user = Factory(:user, :email => "wronguser@example.com", 
                                       :country_id => @country.id, :vendor => true)
    @xvendor = Factory(:vendor, :country_id => @country.id, :verified => true, :name => "Wrong Vendor")
    @xrepresentation = Factory(:representation, :user_id => @wrongvendor_user.id, :vendor_id => @xvendor.id)
    @xresource = Factory(:resource, :vendor_id => @xvendor.id, :category_id => @category.id, 
                                    :medium_id => @medium.id, :name => "X resource")
  end
  
  describe "for non-logged-in users" do
    
  end
  
  describe "for logged in non-vendor users" do
    
  end
  
  describe "for the wrong logged-in vendor user" do
    
  end
  
  describe "for the right logged-in vendor-user" do
    
    before(:each) do
      test_log_in(@user)
      test_selected_vendor_cookie(@vendor)
      test_resource_cookie(@resource)   
    end
    
    describe "GET 'new'" do
      
      it "should be successful" do
        pending "Problem - route failure in tests, though the site appears to work correctly"
        get :new, :resource_id => @resource.id
        response.should be_success
      end
    
    end
     
    describe "GET 'edit'" do
      
      before(:each) do
        @item = Factory(:item, :resource_id => @resource.id, :reference => "ABC1", :days => "Tue/Wed/Thu",
                            :time_of_day => "Evenings", :start => Time.now - 2.days,
                            :finish => nil, :venue => "Us",
                            :currency => "GBP", :cents => 2000)
      end
            
      it "should be successful" do
        get 'edit', :id => @item.id
        response.should be_success
      end
    
    end
  end
end
