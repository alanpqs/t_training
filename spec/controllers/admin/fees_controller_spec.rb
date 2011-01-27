require 'spec_helper'

describe Admin::FeesController do

  render_views
  
  before(:each) do
    @region = Factory(:region)
    @country = Factory(:country, :region_id => @region.id)
    @user = Factory(:user, :country_id => @country.id)
    @fee_a = Factory(:fee)
    @fee_b = Factory(:fee, :band => "B", :bottom_of_range => 20.00, :top_of_range => 49.99,
                       :cents => 200)
    @fee_c = Factory(:fee, :band => "C", :bottom_of_range => 50.00, :top_of_range => 100000,
                       :cents => 300)
    @fees = [@fee_a, @fee_b, @fee_c]  
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
        get :new
        response.should_not be_success
      end
      
      it "should redirect to the login path" do
        get :new
        response.should redirect_to login_path
      end
    end
    
    describe "POST 'create'" do
      
      before(:each) do
        @attr = { :band => "D", :bottom_of_range => 100.00, :top_of_range => 199.99,
                                     :cost => 400.00 }
      end
      
      it "should not create a new band" do
        lambda do
          post :create, :fee => @attr
        end.should_not change(Fee, :count)
      end
      
      it "should redirect to the root path" do
        post :create, :fee => @attr
        response.should redirect_to root_path
      end
    end
    
    describe "GET 'edit'" do

      it "should_not be successful" do
        get :edit, :id => @fee_a
        response.should_not be_success
      end
      
      it "should redirect to the login path" do
        get :edit, :id => @fee_a
        response.should redirect_to login_path
      end
    end
    
    describe "PUT 'update'" do
      
      before(:each) do
        @attr = { :band => "Z", :bottom_of_range => 300.00, :top_of_range => 499.99,
                    :cost => 6.00 }  
      end
      
      it "should not change the band's attributes" do
        put :update, :id => @fee_c, :fee => @attr
        #medium = assigns(:medium)
        @fee_c.reload
        @fee_c.band.should_not == "Z"
      end
      
      it "should redirect to the root path" do
        put :update, :id => @fee_c, :fee => @attr
        response.should redirect_to root_path
      end
    end
    
    describe "DELETE 'destroy'" do
      
      it "should redirect to the login path" do
        delete :destroy, :id => @fee_b
        response.should redirect_to(login_path)
      end
      
      it "should not change the total of bands" do
        lambda do
          delete :destroy, :id => @fee_b
        end.should_not change(Fee, :count)
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
      
      it "should redirect to the root path" do
        get :index
        response.should redirect_to root_path
      end
    end

    describe "GET 'new'" do
      it "should not be successful" do
        get :new
        response.should_not be_success
      end
      
      it "should redirect to the root path" do
        get :new
        response.should redirect_to root_path
      end
    end
    
    describe "POST 'create'" do
      
      before(:each) do
        @attr = { :band => "D", :bottom_of_range => 100.00, :top_of_range => 199.99,
                                     :cost => 400.00 }
      end
      
      it "should not create a new band" do
        lambda do
          post :create, :fee => @attr
        end.should_not change(Fee, :count)
      end
      
      it "should redirect to the root path" do
        post :create, :fee => @attr
        response.should redirect_to root_path
      end
    end
    
    describe "GET 'edit'" do
      
      it "should_not be successful" do
        get :edit, :id => @fee_a
        response.should_not be_success
      end
      
      it "should redirect to the root path" do
        get :edit, :id => @fee_a
        response.should redirect_to root_path
      end
    end
    
    describe "PUT 'update'" do
      
      before(:each) do
        @attr = { :band => "Z", :bottom_of_range => 300.00, :top_of_range => 499.99,
                    :cost => 6.00 }  
      end
      
      it "should not change the band's attributes" do
        put :update, :id => @fee_c, :fee => @attr
        #medium = assigns(:medium)
        @fee_c.reload
        @fee_c.band.should_not == "Z"
      end
      
      it "should redirect to the root path" do
        put :update, :id => @fee_c, :fee => @attr
        response.should redirect_to root_path
      end
    end
    
    describe "DELETE 'destroy'" do
      
      it "should redirect to the root path" do
        delete :destroy, :id => @fee_b
        response.should redirect_to(root_path)
      end
      
      it "should not change the total of bands" do
        lambda do
          delete :destroy, :id => @fee_b
        end.should_not change(Fee, :count)
      end
    end
  end
  
  describe "for logged-in admins" do
  
    before(:each) do
      @admin = Factory(:user, :name => "Admin", :email => "admin@example.com", 
                              :admin => true, :country_id => @country.id)
      test_log_in(@admin)               
    end
    
    describe "GET 'index'" do
      it "should be successful" do
        get :index
        response.should be_success
      end
      
      it "should have the right title" do
        get :index
        response.should have_selector("title", :content => "Ticket costs")
      end
      
      it "should display a row for each band, with a link to the edit form" do
        get :index
        @fees.each do |fee|
          response.should have_selector("a", :href => edit_admin_fee_path(fee))
        end
      end
      
      it "should have a 'band' column" do
        get :index
        response.should have_selector("td", :content => "B")
      end
      
      it "should have a 'bottom_of_range' column, displaying 2 decimal places" do
        get :index
        response.should have_selector("td", :content => "0.00")
      end
      
      it "should have a 'top_of_range' column, displaying 2 decimal places" do
        get :index
        response.should have_selector("td", :content => "19.99")
      end
      
      it "should display 'and above' in the top_of_range column, if the value is 100000" do
        get :index
        response.should have_selector("td", :content => "and above")
      end
      
      it "should have a 'cost' column, displaying 2 decimal places" do
       get :index
        response.should have_selector("td", :content => "1.00")
      end
      
      it "should have a delete control, if the band has never been used for ticket issues" do
        pending "need to complete ticket issues first"
      end
      
      it "should not have a delete control, if the band has been previously used for ticket issues" do
        pending "need to complete ticket issues first"
      end
      
      it "should have a 'New Band' button" do
        get :index
        response.should have_selector("a", :href => new_admin_fee_path,
                                           :content => "Add a new band")
      end
      
      it "should advise that all values are in dollars" do
        get :index
        response.should have_selector(".notes", :content => "US dollars")
      end
      
    end

    describe "GET 'new'" do
      it "should be successful" do
        get :new
        response.should be_success
      end
      
      it "should have the right title" do
        get :new
        response.should have_selector("title", :content => "Add a new fee-band")
      end
      
      it "should advise that all values are in dollars" do
        get :new
        response.should have_selector(".notes", :content => "US dollars")
      end
      
      it "should have an empty text-field box for 'band'" do
        get :new
        response.should have_selector("input", :name => "fee[band]",
                                               :content => "")
      end
      
      it "should have an empty text-field box for 'bottom_of range'" do
        get :new
        response.should have_selector("input", :name => "fee[bottom_of_range]",
                                               :content => "")
      end
      
      it "should have an empty text-field box for 'top_of range'" do
        get :new
        response.should have_selector("input", :name => "fee[top_of_range]",
                                               :content => "")
      end
      
      it "should have a text-field box for 'cost' defaulting to 0.00" do
        get :new
        response.should have_selector("input", :name => "fee[cost]",
                                               :value => "0.00")
      end
      
      it "should have a 'Create' submit button" do
        get :new
        response.should have_selector("input", :value => "Create")
      end
      
      it "should have a 'Cancel' link" do
        get :new
        response.should have_selector("a",  :href => admin_fees_path, :content => "(cancel)" )
      end
      
    end
    
    describe "POST 'create'" do
      
      before(:each) do
        @bad_attr = { :band => "DD", :bottom_of_range => 100.00, :top_of_range => 199.99,
                                     :cost => 400.00 }
        @good_attr = { :band => "D", :bottom_of_range => 100.00, :top_of_range => 199.99,
                                     :cost => 400.00 }
      end  
        
      describe "success" do
        
        it "should add a new band to fees" do
          lambda do
            post :create, :fee => @good_attr
          end.should change(Fee, :count).by(1)
        end
        
        it "should redirect to the fees index path" do
          post :create, :fee => @good_attr
          response.should redirect_to admin_fees_path
        end
        
        it "should have a success message" do
          post :create, :fee => @good_attr
          flash[:success].should =~ /New band created/
        end
      end
      
      describe "failure" do
        
        it "should not add a new band in fees" do
          lambda do
            post :create, :fee => @bad_attr
          end.should_not change(Fee, :count)
        end
        
        it "should render the 'new' page again" do
          post :create, :fee => @bad_attr
          response.should render_template("admin/fees/new")
        end
        
        it "should have the right title" do
          post :create, :fee => @bad_attr
          response.should have_selector("title", :content => "Add a new fee-band")
        end
        
        it "should display a failure message" do
          post :create, :fee => @bad_attr
          response.should have_selector("div#error_explanation", :content => "There were problems")
        end
        
      end
      
    end  
      
    describe "GET 'edit'" do
        
      it "should be successful" do
        get :edit, :id => @fee_a
        response.should be_success
      end
      
      it "should have the right title" do
        get :edit, :id => @fee_a
        response.should have_selector("title", :content => "Change fees")
      end
      
      it "should advise that all values are in dollars" do
        get :edit, :id => @fee_a
        response.should have_selector(".notes", :content => "US dollars")
      end
      
      it "should have a text-field box for 'band'" do
        get :edit, :id => @fee_a
        response.should have_selector("input", :name => "fee[band]",
                                               :value => "A")
      end
      
      it "should have a text-field box for 'bottom_of range'" do
        get :edit, :id => @fee_a
        response.should have_selector("input", :name => "fee[bottom_of_range]",
                                               :value => "0.0")
      end
      
      it "should have a text-field box for 'top_of range'" do
        get :edit, :id => @fee_a
        response.should have_selector("input", :name => "fee[top_of_range]",
                                               :value => "19.99")
      end
      
      it "should have a text-field box for 'cost' with the correct current value" do
        get :edit, :id => @fee_a
        response.should have_selector("input", :name => "fee[cost]",
                                               :value => "1.00")
      end
      
      it "should have a 'Confirm changes' submit button" do
        get :edit, :id => @fee_a
        response.should have_selector("input", :value => "Confirm changes")
      end
      
      it "should have a 'drop changes' link" do
        get :edit, :id => @fee_a
        response.should have_selector("a", :content => "(drop changes)" )
      end
      
    end
  
    describe "PUT 'update'" do
      
      describe "success" do
      
        before(:each) do
          @attr = { :band => "Z", :bottom_of_range => 300.00, :top_of_range => 499.99,
                    :cost => 6.00 }  
        end
        
        it "should successfully change the band's attributes" do
          put :update, :id => @fee_c, :fee => @attr
          fee = assigns(:fee)
          @fee_c.reload
          @fee_c.band.should == fee.band
          @fee_c.bottom_of_range.should == fee.bottom_of_range
          @fee_c.cents.should == 600
        end
        
        it "should redirect to the index page" do
          put :update, :id => @fee_c, :fee => @attr
          response.should redirect_to admin_fees_path
        end
        
        it "should display a success message" do
          put :update, :id => @fee_c, :fee => @attr
          flash[:success].should =~ /Band updated/
        end 
      end
      
      describe "failure" do
        before(:each) do
          @attr = { :band => "ZZ", :bottom_of_range => 300.00, :top_of_range => 499.99,
                    :cost => 6.00 }
        end
        
        it "should not change the band's attributes" do
          put :update, :id => @fee_c, :fee => @attr
          fee = assigns(:fee)
          @fee_c.reload
          @fee_c.band.should_not == fee.band
        end
        
        it "should render the edit page again" do
          put :update, :id => @fee_c, :fee => @attr
          response.should render_template("edit")
        end
        
        it "should have the correct title" do
          put :update, :id => @fee_c, :fee => @attr
          response.should have_selector("title", :content => "Change fees")
        end
        
        it "should display an error message" do
          put :update, :id => @fee_c, :fee => @attr
          response.should have_selector("div#error_explanation", :content => "There were problems")
        end
      end
    end
    
    describe "DELETE 'destroy'" do
      
      describe "success" do
        
        it "should decrease the number of bands by one" do
          lambda do
            delete :destroy, :id => @fee_c
          end.should change(Fee, :count).by(-1)
        end
        
        it "should redirect to the fees index page" do
          delete :destroy, :id => @fee_c
          response.should redirect_to admin_fees_path
        end
        
        it "should display a message showing what has been deleted" do
          delete :destroy, :id => @fee_c
          flash[:success].should == "Band #{@fee_c.band} deleted."
        end
      end
      
      describe "failure" do
        
        it "should not decrease the number of bands" do
          pending "till before_delete callback added"
        end
      end
    end 
  end

end
