require 'spec_helper'

describe Admin::CitiesController do

  render_views
  
  before(:each) do
    @region = Factory(:region)
    @country = Factory(:country, :region_id => @region.id)
    @user = Factory(:user, :country_id => @country.id)
    @city = Factory(:city, :country_id => @country.id)
    @good_attr = { :name => "Pqs", :latitude => 55.8656274, :longitude => -4.2572227 }
    @bad_attr = { :name => "", :latitude => 95.8656274, :longitude => -184.2572227 }
  end
  
  describe "for non-logged-in users" do
    
    describe "GET 'index'" do
      it "should not be successful" do
        get :index
        response.should_not be_success
      end
    end
    
    describe "GET 'edit'" do
      it "should not be successful" do
        get :edit, :id => @city
        response.should_not be_success
      end
    end
    
    describe "PUT 'update'" do
      
      it "should not change the city's attributes" do
        put :update, :id => @city, :city => @good_attr
        @city.reload
        @city.name.should_not == @good_attr[:name]
      end
      
      it "should redirect to the root path" do
        put :update, :id => @city, :city => @good_attr
        response.should redirect_to root_path
      end
    end
    
    describe "DELETE 'destroy'" do
      
      it "should not delete the record" do
        lambda do
          delete :destroy, :id => @city
        end.should_not change(City, :count)
      end
      
      it "should redirect to the login page" do
        delete :destroy, :id => @city
        response.should redirect_to login_path
      end
    end
  end
  
  describe "for logged-in non-admins" do
    
    before(:each) do
      test_log_in(@user)
    end
    
    describe "GET 'index'" do
      it "should not be successful" do
        get :index
        response.should_not be_success
      end
    end
    
    describe "GET 'edit'" do
      it "should not be successful" do
        get :edit, :id => @city
        response.should_not be_success
      end
    end
    
    describe "PUT 'update'" do
      
      it "should not change the city's attributes" do
        put :update, :id => @city, :city => @good_attr
        @city.reload
        @city.name.should_not == @good_attr[:name]
      end
      
      it "should redirect to the root path" do
        put :update, :id => @city, :city => @good_attr
        response.should redirect_to root_path
      end
    end
    
    describe "DELETE 'destroy'" do
      
      it "should not delete the record" do
        lambda do
          delete :destroy, :id => @city
        end.should_not change(City, :count)
      end
      
      it "should redirect to the login page" do
        delete :destroy, :id => @city
        response.should redirect_to root_path
      end
    end
  end
  
  describe "for logged-in admins" do 
  
    before(:each) do
      @admin = Factory(:user, :email => "admin@example.com", :admin => true, :country_id => @country.id)
      test_log_in(@admin)
      @country2 = Factory(:country, :name => "Country2", :country_code => "CTZ", :region_id => @region.id)
      @city2 = Factory(:city, :name => "Second City", :country_id => @country.id)
      @foreign_city = Factory(:city, :name => "Foreign City", :country_id => @country2.id)
      @almost_located_city = Factory(:city, :name => "Almost Located City", :latitude => 50, 
                               :country_id => @country2.id)
      @identified_city = Factory(:city, :name => "Identified City", :latitude => 50, 
                               :longitude => -50, :country_id => @country.id)
      @cities = [@city, @city2, @foreign_city, @almost_located_city, @identified_city]
    end
    
    describe "GET 'index'" do
      it "should be successful" do
        get :index
        response.should be_success
      end
      
      it "should have the right title" do
        get :index
        response.should have_selector("title", :content => "New cities added")
      end
      
      it "should list each of the cities where geolocation has not been set" do
        get :index
        @cities[0..3].each do |city|
          response.should have_selector("td", :content => city.name)
        end
      end
      
      it "should not include cities where geolocation has been set" do
        get :index
        @cities[4..4].each do |city|
          response.should_not have_selector("td", :content => city.name)
        end
      end
      
      it "should have an 'edit' link for each city" do
        get :index
        @cities[0..3].each do |city|
          response.should have_selector("a", :href => edit_admin_city_path(city.id))
        end
      end
      
      it "should have a delete link if the city is not connected to a user" do
        get :index
        @cities[2..3].each do |city|
          response.should have_selector("a",  :href => "/admin/cities/#{city.id}",
                                              :content => "delete")
        end
      end
      
      it "should not have a delete link if the city is connected to a user" do
        pending "until user city links are added"
        #get :index
        #@cities[0..1].each do |city|
         # response.should_not have_selector("a",  :href => "/admin/cities/#{city.id}",
        #                                          :content => "delete")
        #end
      end
      
      it "should include the country with which the city is associated" do
        get :index
        @cities[0..3].each do |city|
          response.should have_selector("td", :content => city.country.name)
        end
      end 
    end
    
    describe "GET 'edit'" do
      it "should be successful" do
        get :edit, :id => @city
        response.should be_success
      end
      
      it "should have the right title" do
        get :edit, :id => @city
        response.should have_selector("title", :content => "Edit city details")
      end
      
      it "should have an editable name field, with the correct city name" do
        get :edit, :id => @city
        response.should have_selector("input",  :name => "city[name]",
                                                :value => @city.name)
      end
      
      it "should have an uneditable country field" do
        get :edit, :id => @city
        response.should have_selector("p",  :content => @city.country.name)
      end
      
      it "should have an editable latitude field" do
        get :edit, :id => @city
        response.should have_selector("input",  :name => "city[latitude]",
                                                :content => @city.latitude)
      end
      
      it "should have an editable longitude field" do
        get :edit, :id => @city
        response.should have_selector("input",  :name => "city[longitude]",
                                                :content => @city.longitude)
      end
      
      it "should have a submit button" do
        get :edit, :id => @city
        response.should have_selector("input.action_round", :value => "Confirm changes")
      end
      
      it "should include a list of all cities in this country" do
        get :edit, :id => @city
        @cities[0..1].each do |city|
          response.should have_selector("div#list_display", :content => city.name)
        end
      end
      
      it "should not include cities from other countries in the list" do
        get :edit, :id => @city
        @cities[2..3].each do |city|
          response.should_not have_selector("div#list_display", :content => city.name)
        end
      end
      
      it "should have a 'drop changes' link" do
        get :edit, :id => @city
        response.should have_selector("a",    :href => admin_cities_path,
                                              :content => "(drop changes)" )
      end
      
    end
    
    describe "PUT 'update'" do
      
      #before(:each) do
      #  @good_attr = { :name => "Pqs", :latitude => 55.8656274, :longitude => -4.2572227 }
      #  @bad_attr = { :name => "", :latitude => 95.8656274, :longitude => -184.2572227 }
        
      #end
      
      describe "success" do
        
        it "should update the city's attributes" do
          put :update, :id => @city, :city => @good_attr
          city = assigns(:city)
          @city.reload
          @city.name.should == city.name
        end
        
        it "should redirect to the list of non-geocoded cities" do
          put :update, :id => @city, :city => @good_attr
          response.should redirect_to admin_cities_path
        end
        
        it "should give a message that the correct city has been successfully changed" do
          put :update, :id => @city, :city => @good_attr
          @city.reload
          flash[:success].should == "#{@city.name} successfully updated"
        end
      end
      
      describe "failure" do
        
        it "should not update the city's attributes" do
          put :update, :id => @city, :city => @bad_attr
          city = assigns(:city)
          @city.reload
          @city.name.should_not == city.name
        end
        
        it "should render the 'edit' page" do
          put :update, :id => @city, :city => @bad_attr
          response.should render_template("edit")
        end
        
        it "should explain what went wrong in an error message" do
          put :update, :id => @city, :city => @bad_attr
          response.should have_selector("div#error_explanation", :content => "There were problems")
        end
      end
      
    end
    
    describe "DELETE 'destroy'" do
      
      describe "success" do
        it "should delete the record" do
          lambda do
            delete :destroy, :id => @city
          end.should change(City, :count).by(-1)
        end
      
        it "should redirect to the list of non-geolocated cities" do
          delete :destroy, :id => @city
          response.should redirect_to admin_cities_path
        end
      
        it "should display a success message" do
          delete :destroy, :id => @city
          flash[:success].should == "#{@city.name} has been deleted."
        end
        
      end
      
      describe "failure" do
        
        it "should not delete the record" do
          pending "till user associations are added"
        end
      
        it "should redirect to the list of non-geolocated cities" do
          pending "till user associations are added"
        end
      
        it "should display a failure message" do
          pending "till user associations are added"
        end
        
      end
      
          
    end
    
  end
end
