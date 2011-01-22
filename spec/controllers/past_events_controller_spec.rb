require 'spec_helper'

describe PastEventsController do

  render_views
  
  require 'money'
  
  before(:each) do
    @region = Factory(:region)
    @country = Factory(:country, :name => "United Kingdom", :currency_code => "GBP", :region_id => @region.id)
    @user = Factory(:user, :country_id => @country.id, :vendor => true)
    @vendor = Factory(:vendor, :country_id => @country.id, :verified => true)
    @representation = Factory(:representation, :user_id => @user, :vendor_id => @vendor)
    @medium = Factory(:medium, :user_id => @user.id, :scheduled => true)
    @category = Factory(:category, :user_id => @user.id, :authorized => true)
    @resource = Factory(:resource, :vendor_id => @vendor.id, :category_id => @category.id, 
                                   :medium_id => @medium.id)
    @item1 = Factory(:item, :resource_id => @resource.id, :currency => "GBP", :cents => 1500, 
                                                :start => Date.today - 20.days, :finish => Date.today - 10.days)
    @item2 = Factory(:item, :resource_id => @resource.id, :reference => "ABC1", :days => "Tue/Wed/Thu",
                            :time_of_day => "Evenings", :start => Date.today - 10.days,
                            :finish => Time.now - 2.days,
                            :currency => "GBP", :cents => 2000)
  
  end


  describe "GET 'index'" do
    
    before(:each) do
      test_log_in(@user)
      test_selected_vendor_cookie(@vendor)
      test_resource_cookie(@resource)     
    end
    
    it "should be successful" do
      get :index, :resource_id => @resource.id
      response.should be_success
    end
  end


end
