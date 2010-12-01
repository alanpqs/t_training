require 'spec_helper'

describe CitiesController do

  render_views
  
  before(:each) do
    @region = Factory(:region)
    @country = Factory(:country, :region_id => @region.id)
    @user = Factory(:user, :country_id => @country.id)
  end
  
  describe "for non-logged-in users" do
    
    describe "GET 'index'" do
      
      it "should not be successful" do
        get :index, :country_id => @country
        response.should_not be_success
      end
      
      it "should redirect to the login page" do
        get :index, :country_id => @country
        response.should redirect_to login_path
      end
    end

    describe "GET 'new'" do
      
      it "should not be successful" do
        get :new, :country_id => @country
        response.should_not be_success
      end
      
      it "should redirect to the login page" do
        get :new, :country_id => @country
        response.should redirect_to login_path
      end
    end
    
  end
  
  describe "for logged-in users" do
    
    before(:each) do
      test_log_in(@user)
      @attr = { :country_id => @country }
    end
    
    describe "GET 'index'" do
      
      it "should be successful" do
        get :index, @attr
        response.should be_success
      end
    end

    describe "GET 'new'" do
      
      it "should be successful" do
        get :new, @attr
        response.should be_success
      end
      
      it "should have the right title including the correct country link" do
        get :new, @attr
        response.should have_selector("title", :content => "New city in #{@country.name}")
      end
      
      it "should have an empty editable 'Name' field" do
        get :new, @attr
        response.should have_selector("input",  :name => "city[name]",
                                                :content => "")
      end
      
      it "should have a 'Create' button" do
        get :new, @attr
        response.should have_selector("input", :value => "Create")
      end
      
      it "should list all current cities for the country" do
        pending
      end
      
      it "should have a 'previous page' link" do
        get :new, @attr
        response.should have_selector("a", :content => "(previous page)", 
                                           :href => user_path(@user))
      end
    end
    
    describe "POST 'create'" do
      
      before(:each) do
        @city_name = "Xyz"
        @attr_good = { :country_id => @country, :city => { :name => @city_name }}
        @attr_bad =  { :country_id => @country, :city => { :name => "" }}
      end
      
      describe "success" do
        
        it "should create a new city record" do
          lambda do
            post :create, @attr_good
          end.should change(City, :count).by(1)
        end
        
        it "should associate the city with the correct country" do
          post :create, @attr_good 
          @new_city = City.find(:last)
          @new_city.country_id.should == @country.id
        end
        
        it "should redirect to the 'index' page, listing cities in the given country" do
          post :create, @attr_good
          response.should redirect_to country_cities_path(@country) 
        end
        
        it "should display a success message" do
          post :create, @attr_good
          flash[:success].should == "#{@city_name} has been added."
        end
      end
      
      describe "failure" do
        
        it "should not create a new city" do
          lambda do
            post :create, @attr_bad
          end.should_not change(City, :count)
        end
        
        it "should render the 'new' page again" do
          post :create, @attr_bad
          response.should render_template("cities/new")
        end
        
        it "should have the right title and country" do
          post :create, @attr_bad 
          response.should have_selector("title", :content => "New city in #{@country.name}")
        end
        
        it "should display a relevant error message" do
          post :create, @attr_bad
          response.should have_selector("div#error_explanation", :content => "There were problems")
        end
      end  
    end
  end
  
  describe "special features for logged-in admins" do
    
    before(:each) do
      @admin = Factory(:user, :email => "admin@example.com", :admin => true, 
                       :country_id => @country.id)
      test_log_in(@admin)
      @attr = { :country_id => @country }
    end
    
    describe "GET 'new'" do
      
      it "should have a 'previous page' link" do
        get :new, @attr
        response.should have_selector("a", :content => "(previous page)", 
                                           :href => admin_country_path(@country))
      end
    end
    
    describe "POST 'create'" do
      
      before(:each) do
        @city_name = "Xyz"
        @attr_good = { :country_id => @country, :city => { :name => @city_name }}
      end
      
      describe "success" do
        
        it "should redirect to the relevant 'country/show' page" do
          post :create, @attr_good
          response.should redirect_to admin_country_path(@country) 
        end
      
      end
      
    end
  end
end
