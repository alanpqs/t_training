require 'spec_helper'

describe Admin::CountriesController do

  render_views
  
  describe "for non-logged-in users" do
    
    before(:each) do
      @country = Factory(:country)
      @attr = { :name => "Foo", :country_code => "FOO", :currency_code => "FOP",
                :phone_code => "1-234", :region => 1
      }
    end
    
    describe "GET 'index'" do
    
      it "should deny access" do
        get "index"
        response.should redirect_to(login_path)
      end
    end
    
    describe "GET 'show'" do
      
      it "should deny access to the 'show' page" do
        get :show, :id => @country
        response.should_not be_success
      end
      
      it "should redirect to the login page" do
        get :show, :id => @country
        response.should redirect_to(login_path)
      end 
    end 
  
    describe "GET 'new'" do
    
      it "should not be successful" do
        get :new
        response.should_not be_success
      end
      
      it "should redirect to the login page" do
        get :new
        response.should redirect_to(login_path)
      end  
    end
    
    describe "POST 'create'" do
     
      it "should not allow non-logged in users to create a new country" do
        lambda do
          post :create, :country => @attr
        end.should_not change(Country, :count)
      end
      
      it "should give non-logged in users a 'Permission denied' notice" do
        post :create, :country => @attr
        flash[:notice].should =~ /Permission denied/i
      end
    end
    
    describe "GET 'edit'" do
      
      it "should not be possible to access the 'edit' form" do
        get :edit, :id => @country
        response.should_not be_success
      end
      
      it "should redirect to the log-in form" do
        get :edit, :id => @country
        response.should redirect_to(login_path)
      end
    end
    
    describe "PUT 'update'" do
    
      it "should redirect to the root path if they try to update Country" do
        put :update, :id => @country, :country => @attr
        response.should redirect_to(root_path)
      end
      
      it "should not change the existing Country attributes" do
        put :update, :id => @country, :country => @attr
        @country.reload
        @country.name.should_not == @attr[:name]
      end
      
    end
    
    describe "DELETE 'destroy'" do
    
      it "should redirect them to the root-path" do
        delete :destroy, :id => @country 
        response.should redirect_to(login_path)
      end
      
      it "should not change the number of Country records" do
        lambda do
          delete :destroy, :id => @country 
        end.should_not change(Country, :count)
      end 
    end
  end
  
  describe "for logged-in non-admins" do
    
    before(:each) do
      @user = Factory(:user)
      @country = Factory(:country)
      @attr = { :name => "Foo", :country_code => "FOO", :currency_code => "FOP",
                :phone_code => "1-234", :region => 1
      }
      test_log_in(@user)
    end
    
    describe "GET 'index'" do
    
      it "should deny access" do
        get "index"
        response.should redirect_to(root_path)
      end
    end
    
    describe "GET 'show'" do
      
      it "should deny access to the 'show' page" do
        get :show, :id => @country
        response.should_not be_success
      end
      
      it "should redirect to the login page" do
        get :show, :id => @country
        response.should redirect_to(root_path)
      end 
    end 
  
    describe "GET 'new'" do
    
      it "should not be successful" do
        get :new
        response.should_not be_success
      end
      
      it "should redirect to the login page" do
        get :new
        response.should redirect_to(root_path)
      end  
    end
    
    describe "POST 'create'" do
     
      it "should not allow non-logged in users to create a new country" do
        lambda do
          post :create, :country => @attr
        end.should_not change(Country, :count)
      end
      
      it "should give non-logged in users a 'Permission denied' notice" do
        post :create, :country => @attr
        flash[:notice].should =~ /Permission denied/i
      end
    end
    
    describe "GET 'edit'" do
      
      it "should not be possible to access the 'edit' form" do
        get :edit, :id => @country
        response.should_not be_success
      end
      
      it "should redirect to the log-in form" do
        get :edit, :id => @country
        response.should redirect_to(root_path)
      end
    end
    
    describe "PUT 'update'" do
    
      it "should redirect to the root path if they try to update Country" do
        put :update, :id => @country, :country => @attr
        response.should redirect_to(root_path)
      end
      
      it "should not change the existing Country attributes" do
        put :update, :id => @country, :country => @attr
        @country.reload
        @country.name.should_not == @attr[:name]
      end
      
    end
    
    describe "DELETE 'destroy'" do
    
      it "should redirect them to the root-path" do
        delete :destroy, :id => @country 
        response.should redirect_to(root_path)
      end
      
      it "should not change the number of Country records" do
        lambda do
          delete :destroy, :id => @country 
        end.should_not change(Country, :count)
      end 
    end
    
  end
 
  describe "for logged-in admins" do
    
    before(:each) do
      @user   =   Factory(:user, :admin => true)
      @country =  Factory(:country)
      @attr = { :name => "Foo", :country_code => "FOO", :currency_code => "FOP",
                :phone_code => "1-234", :region => 1
      }
      
      test_log_in(@user)
    end
    
    describe "GET 'index'" do
      
      before(:each) do
        @region   = Factory(:region, :region => "ZYX")
        @second   = Factory(:country, :name => "ZYZ", :country_code => "ZZZ", :region => @region )
        @third    = Factory(:country, :name => "YZY", :country_code => "YYY", :region => @region )
        @countries = [@country, @second, @third]
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
          response.should have_selector("a",  :href => "/admin/countries/#{country.id}",
                                              :content => "delete")
        end
      end
      
      it "should paginate countries" do
        30.times do
          @countries << Factory(:country, :name => Factory.next(:name), 
                                :country_code => Factory.next(:country_code),
                                :region => @region)
        end
        get :index
        response.should have_selector("div.pagination")
        response.should have_selector("span.disabled", :content => "Previous")
        response.should have_selector("a",  :href => "/admin/countries?page=2",
                                            :content => "2")
        response.should have_selector("a",  :href => "/admin/countries?page=2",
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
        response.should have_selector("a",   :href     => "/admin/countries/new",
                                             :content  => "New country")
      end     
      
    end
    
    describe "GET 'show'" do
      
      it "should successfully display the 'show' page" do
        get :show, :id => @country
        response.should be_success
      end
      
      it "should not fail if the currency selected is no longer in the 'Money' list" do
        @region = Factory(:region, :region => "PQS")
        @attr = { :name => "Bbb", :country_code => "BBB", :currency_code => "IMP", 
                :phone_code => "+57", :region_id => @region.id }
        @no_currcode_country = Factory(:country, @attr)
        get :show, :id => @no_currcode_country
        response.should be_success
      end
      
      it "should find the right country" do
        get :show, :id => @country
        assigns(:country).should == @country
      end
      
      it "should have the right title" do
        get :show, :id => @country
        response.should have_selector("title", :content => @country.name)
      end
      
      it "should have the right header" do
        get :show, :id => @country
        response.should have_selector("h1", :content => @country.name)
      end
      
      it "should have a link to the Country 'edit' page" do
        get :show, :id => @country
        response.should have_selector("a",    :href     => edit_admin_country_path(@country),
                                              :content  => "(edit details)")
      end
      
      it "should display 'Unknown' if the exchange rate is not known" do
        #Factory currency is Japanese Yen - assume rate is always known
        #We'll use Malawi Kwacha - assume rate not known'
        #NOT YET TESTING FOR NUMERIC RATE VALUE
        @no_exchange_country = @country.update_attribute(:currency_code, "MWK")
        get :show, :id => @country
        response.should have_selector("span.rate",  :content => "Unknown")
      end
    end
    
    describe "GET 'new'" do
      
      it "should be successful" do
        get :new
        response.should be_success
      end
      
      it "should have the right title" do
        get :new
        response.should have_selector("title", :content => "New country")
      end
      
      it "should have an empty Currency_code select-box" do
        get :new
        response.should have_selector("select", :name => "country[currency_code]",
                                                :content => "")
      end
      
      it "should have the correct options in the Currency_code select box" do
        
        #list of currencies generated by Money gem; 
        #these common currencies always likely to be available
        
        currencies = ["USD", "JPY", "ZAR"]    
        get :new
        currencies.each do |c|
          response.should have_selector("option", :value => c)
        end
      end
      
      it "should have a Create button" do
        get :new
        response.should have_selector("input", :value => "Create")
      end
      
      it "should not have a 'Drop changes' link to the Country 'show' form" do
        get :new
        response.should_not have_selector("a", :content => "(drop changes)" )
      end
    end
    
    describe "POST 'create'" do
      
      before(:each) do
        @region = Factory(:region, :region => "MNM")
        @attr = { :name => "PPP", :country_code => "PPP", :currency_code => "EUR", 
                :phone_code => "+57", :region_id => @region.id }
        @attr_blank = { :name => "", :country_code => "", :currency_code => "EUR", 
                :phone_code => "57", :region_id => @region.id }    
      end
      
      describe "successfully create country" do
        it "should create a new country" do
          lambda do
            post :create, :country => @attr
          end.should change(Country, :count).by(1)
        end
        
        it "should display a success message" do
          post :create, :country => @attr
          flash[:success].should =~ /New country created/i   
        end
        
        it "should redirect to the Country 'show' page" do
          post :create, :country => @attr
          response.should redirect_to(admin_country_path(assigns(:country)))
        end
      end
      
      describe "fail to create country" do
        
        it "should not create a new country" do
          lambda do
            post :create, :country => @attr_blank
          end.should_not change(Country, :count)
        end
  
        it "should display an error message" do
          post :create, :country => @attr_blank
          response.should have_selector("div#error_explanation", :content => "There were problems")
        end
        
        it "should have the right title" do
          post :create, :country => @attr_blank
          response.should have_selector("title", :content => "New country")
        end
      
        it "should return to the 'new' page" do
          post :create, :country => @attr_blank
          response.should render_template("admin/countries/new")
        end
      end
    end
    
    describe "GET 'edit'" do
      
      it "should be successful" do
        get :edit, :id => @country
        response.should be_success
      end
    
      it "should have the right title" do
        get :edit, :id => @country
        response.should have_selector(:title, :content => "Edit #{@country.name}")
      end
    
      it "should have selected the right country and have the right header" do
        get :edit, :id => @country
        response.should have_selector("h1", :content => "Edit #{@country.name}")
      end
      
      it "should have a select field for Currency_code with the correct currency displayed" do
        get :edit, :id => @country
        response.should have_selector("select", :name => "country[currency_code]",
                                                :content => @country.currency_code)
      end
      
      it "should have the correct options in the Currency_code select box" do
        
        #list of currencies generated by Money gem; 
        #these common currencies always likely to be available
        
        currencies = ["USD", "JPY", "ZAR"]    
        get :edit, :id => @country
        currencies.each do |c|
          response.should have_selector("option", :value => c)
        end
      end
      
      it "should have a select field for Region_id with the correct region displayed" do
        
        #NOT TESTED
      
      end
      
      it "should have a Confirm button" do
        get :edit, :id => @country
        response.should have_selector("input.action_round", :value => "Confirm changes")
      end
      
      it "should have a 'Drop changes' link to the Country 'show' form" do
        get :edit, :id => @country
        response.should have_selector("a",    :href => admin_country_path(@country),
                                              :content => "(drop changes)" )
      end
    end
    
    describe "PUT 'update'" do
      
      before(:each) do
        @region = Factory(:region, :region => "Bif")
        @valid_attr = { :name => "Baz", :country_code => "BAZ", :currency_code => "USD",
                      :phone_code => "+12345", :region_id => @region.id }
        @bad_attr =   { :name => "", :country_code => "", :currency_code => "",
                        :phone_code => "123", :region_code => @region.id }
        @bad_attr2 =  { :name => "Bad", :country_code => "", :currency_code => "",
                        :phone_code => "123", :region_code => @region.id }
      end
      
      describe "success" do
        
        it "should update the Country attributes" do
          put :update, :id => @country, :country => @valid_attr
          country = assigns(:country)
          @country.reload
          @country.name.should == country.name
          @country.country_code.should == country.country_code
        end
        
        it "should give them a 'Success' message" do
          put :update, :id => @country, :country => @valid_attr
          @country.reload
          flash[:success].should == "#{@country.name} updated."
        end
        
        it "should redirect to the 'show' page" do
          put :update, :id => @country, :country => @valid_attr
          response.should redirect_to admin_country_path(@country)
        end
      end
      
      describe "failure" do
        
        it "should not update the Country attributes" do
          put :update, :id => @country, :country => @bad_attr
          country = assigns(:country)
          @country.reload
          @country.name.should_not == country.name
          @country.country_code.should_not == country.country_code
        end
        
        it "should render the 'edit' template" do
          put :update, :id => @country, :country => @bad_attr
          response.should render_template("admin/countries/edit")
        end
        
        it "should give an error message" do
          put :update, :id => @country, :country => @bad_attr
          response.should have_selector("div#error_explanation", :content => "There were problems")
        end
        
        it "should have the right title if the country name input was blank" do
          put :update, :id => @country, :country => @bad_attr
          response.should have_selector(:title, :content => "Edit country")  
        end
        
        it "should have the right title if the country name input was not blank" do
          put :update, :id => @country, :country => @bad_attr2
          country = assigns(:country)
          response.should have_selector(:title, :content => "Edit #{country.name}")  
        end
      end
    end
    
    describe "DELETE 'destroy'" do
      
      it "should decrease the number of Country records by one" do
        lambda do
          delete :destroy, :id => @country 
        end.should change(Country, :count).by(-1)
      end
      
      it "should not delete the wrong record" do
        Country.create!(:name => "FGH", :country_code => "FGH", :currency_code => "USD",
                    :phone_code => "+456", :region_id => 1)
        @delete_id = Country.find_by_name("FGH").id
        delete :destroy, :id => @delete_id
        get :edit, :id => @country
        response.should be_success
      end
      
      it "should redirect to the Country 'index' list" do
        delete :destroy, :id => @country 
        response.should redirect_to(admin_countries_path)
      end
      
      it "should display the correct success message" do 
        @name = @country.name
        delete :destroy, :id => @country
        flash[:success].should include "#{@name} deleted"     
      end
    end
  end
end
