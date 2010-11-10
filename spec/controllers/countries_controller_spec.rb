require 'spec_helper'

describe CountriesController do

  render_views
  
  describe "GET 'index'" do
    
    describe "for non-logged-in users" do
    
      it "should deny access" do
        get "index"
        response.should redirect_to(login_path)
      end
      
    end
      
    describe "for logged-in admins" do  
      
      before(:each) do
        @user = test_log_in(Factory(:user, :admin => true))
        @region = Factory(:region)
        @country = Factory(:country,  :region => @region)
        second   = Factory(:country,  :name => "ZYZ", :country_code => "ZZZ", 
                                      :region => @region)
        third    = Factory(:country,  :name => "YZY", :country_code => "YYY",
                                      :region => @region)
        
        @countries = [@country, second, third]
      end
      
      it "should be successful" do
        get :index
        response.should be_success
      end
    
      it "should have the right title" do
        get :index
        response.should have_selector("title", :content => "Countries")
      end
      
      it "should have an element for each country" do
        get :index
        @countries[0..2].each do |country|
          response.should have_selector("td", :content => country.name)
        end
      end
      
      it "should have a Delete button for each country" do
        #AMEND LATER - NO DELETION IF CONNECTED ELSEWHERE
        get :index
        @countries[0..2].each do |country|
          response.should have_selector("a",  :href => "/countries/#{country.id}",
                                              :content => "delete")
        end
      end
      
      it "should paginate countries" do
        30.times do
          @countries << Factory(:country, :name => Factory.next(:name), 
                                :country_code => Factory.next(:country_code),
                                :region => @region
          )
        end
        get :index
        response.should have_selector("div.pagination")
        response.should have_selector("span.disabled", :content => "Previous")
        response.should have_selector("a",  :href => "/countries?page=2",
                                            :content => "2")
        response.should have_selector("a",  :href => "/countries?page=2",
                                            :content => "Next")
      end
      
      it "should have a Country column" do
        get :index
        response.should have_selector("th", :content => "Country")
      end
      
      it "should have a Code column" do
        get :index
        response.should have_selector("th", :content => "Code")
      end
      
      it "should have a Currency column" do
        get :index
        response.should have_selector("th", :content => "Currency")
      end
      
      it "should have an IDD column" do
        get :index
        response.should have_selector("th", :content => "IDD")
      end
      
      it "should have a Region column" do
        get :index
        response.should have_selector("th", :content => "Region")
      end
      
      it "should have a 'New country' link" do
        get :index
        response.should have_selector("a",   :href     => "/countries/new",
                                             :content  => "New country")
      end
    end   
  end
  

  #describe "GET 'new'" do
  #  it "should be successful" do
  #    get 'new'
  #    response.should be_success
  #  end
  #end

  describe "GET 'edit'" do
  
    before(:each) do
      @country = Factory(:country)
      admin = Factory(:user, :admin => true)
      test_log_in(admin)  
    end
    
    it "should be successful" do
      get :edit, :id => @country
      response.should be_success
    end
    
    it "should have the right title" do
      get :edit, :id => @country
      response.should have_selector(:title, :content => "Edit #{@country.name}")
    end
  end

  describe "DELETE 'destroy'" do
    
  end

end
