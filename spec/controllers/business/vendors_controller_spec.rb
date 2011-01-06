require 'spec_helper'

describe Business::VendorsController do

  render_views
  
  before(:each) do
    @region = Factory(:region)
    @country = Factory(:country, :region_id => @region.id)
    @vendor = Factory(:vendor, :country_id => @country.id, :description => "Great trainer")
    @vendor2 = Factory(:vendor, :name => "Vendor2", :address => "Birmingham",
                                :country_id => @country.id, :email => "vendor2@example.com")
    @attr = { :name => "goodname", :country_id => @country.id, :address => "Swansea",
                       :email => "goodname@example.com", :description => "Training" }
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
        get :index
        response.should redirect_to login_path
      end
      
    end
    
    
    describe "POST 'create'" do
      
      before(:each) do
        @name = "Xx" 
        @attr = { :name => @name, :country_id => @country.id, 
                  :address => "London", :email => "xx@email.com" }
      end
      
      it "should not add a new vendor" do
        lambda do
          post :create, :vendor => @attr
        end.should_not change(Vendor, :count)  
      end
      
      it "should give non-logged in users a 'Permission denied' notice" do
        post :create, :vendor => @attr
        flash[:notice].should =~ /Permission denied/i
      end
    end
    
    
    describe "GET 'show'" do
      it "should not display the page" do
        get :show, :id => @vendor
        response.should_not be_success
      end
      
      it "should redirect to the login page" do
        get :show, :id => @vendor
        response.should redirect_to login_path
      end
    end
    
    
    describe "GET 'edit'" do
      
      it "should not display the page" do
        get :edit, :id => @vendor
        response.should_not be_success
      end
      
      it "should redirect to the login page" do
        get :edit, :id => @vendor
        response.should redirect_to login_path
      end
    end
    
    describe "PUT 'update'" do
      
      it "should redirect to the root path if they attempt to update a vendor" do
        put :update, :id => @vendor, :vendor => @attr
        response.should redirect_to root_path
      end
      
      it "should not update the vendor attributes" do
        put :update, :id => @vendor, :vendor => @attr
        @vendor.reload
        @vendor.name.should_not == @attr[:name]
      end
    end
    
  end
  
  describe "logged-in non-vendors" do
    
    before(:each) do
      @user = Factory(:user, :country_id => @country.id)
      @attr = { :name => "goodname", :country_id => @country.id, :address => "Swansea",
                       :email => "goodname@example.com", :description => "Training" }
      test_log_in(@user)
    end
    
    describe "GET 'index'" do
      it "should not be successful" do
        get :index
        response.should_not be_success
      end
      
      it "should redirect to the user profile page" do
        get :index
        response.should redirect_to user_path(@user)
      end
    end
    
    
    describe "GET 'show'" do
      it "should not display the page" do
        get :show, :id => @vendor
        response.should_not be_success
      end
      
      it "should redirect to the user home page" do
        get :show, :id => @vendor
        response.should redirect_to user_path(@user)
      end
    end
    
    
    describe "GET 'new'" do
      it "should not be successful" do
        get :new
        response.should_not be_success
      end
      
      it "should redirect to the user profile page" do
        get :index
        response.should redirect_to user_path(@user)
      end
    end
    
    describe "POST 'create'" do
      
      before(:each) do
        @name = "Xx" 
        @attr = { :name => @name, :country_id => @country.id, 
                  :address => "London", :email => "xx@email.com" }
      end
      
      it "should not add a new vendor" do
        lambda do
          post :create, :vendor => @attr
        end.should_not change(Vendor, :count)  
      end
      
      it "should give logged-in non-vendors a 'Permission denied' notice" do
        post :create, :vendor => @attr
        flash[:notice].should =~ /Permission denied/i
      end
    end
    
    describe "GET 'edit'" do
      
      it "should not display the page" do
        get :edit, :id => @vendor
        response.should_not be_success
      end
      
      it "should redirect to the user home page" do
        get :edit, :id => @vendor
        response.should redirect_to user_path(@user)
      end
    end
    
    describe "GET 'update'" do
      
      it "should redirect to the root path if they attempt to update a vendor" do
        put :update, :id => @vendor, :vendor => @attr
        response.should redirect_to user_path(@user)
      end
      
      it "should not update the vendor attributes" do
        put :update, :id => @vendor, :vendor => @attr
        @vendor.reload
        @vendor.name.should_not == @attr[:name]
      end
    end
  end
  
  describe "logged-in vendor-users, associated with vendor(s)" do
  
    before(:each) do
      @user = Factory(:user, :vendor => true, :country_id => @country.id)
      @representation = Factory(:representation, :user_id => @user.id, :vendor_id => @vendor.id)
      test_log_in(@user)
    end
    
    describe "GET 'index'" do
      it "should be successful" do
        pending "should perhaps scrap index - business/home instead"
        #response.should be_success
      end 
    end

    describe "GET 'new'" do
      it "should be successful" do
        get :new
        response.should be_success
      end
      
      it "should have the right title" do
        get :new
        response.should have_selector("title", :content => "New vendor")
      end
      
      it "should have an empty entry field for 'name'" do
        get :new
        response.should have_selector("input",  :name => "vendor[name]")
      end
      
      it "should show that the name field is required" do
        get :new
        response.should have_selector("div#name", :content => "*")
      end
      
      it "should have an entry field for 'country', preset to the user's country" do
        get :new
        response.should have_selector("option", :value => @user.country.id.to_s,
                                                :selected => "selected",
                                                :content => @user.country.name)
      end
      
      it "should show that the country field is required" do
        get :new
        response.should have_selector("div#country", :content => "*")
      end
      
      it "should have an empty entry field for 'address'" do
        get :new
        response.should have_selector("input",  :name => "vendor[address]")
      end
      
      it "should show that the address field is required" do
        get :new
        response.should have_selector("div#address", :content => "*")
      end
      
      it "should have an empty entry field for 'email'" do
        get :new
        response.should have_selector("input",  :name => "vendor[email]")
      end
      
      it "should show that the email field is required" do
        get :new
        response.should have_selector("div#email", :content => "*")
      end
      
      
      it "should have an empty entry field for 'phone'" do
        get :new
        response.should have_selector("input",  :name => "vendor[phone]")
      end
      
      it "should have an empty entry field for 'website'" do
        get :new
        response.should have_selector("input",  :name => "vendor[website]")
      end
      
      it "should have an empty text_area field for 'description'" do
        get :new
        response.should have_selector("textarea",  :name => "vendor[description]")
      end
      
      it "should have a 'Create' button" do
        get :new
        response.should have_selector("input", :value => "Create")
      end
      
      it "should not have a 'Drop changes' link to the Country 'show' form" do
        get :new
        response.should_not have_selector("a", :content => "(drop changes)" )
      end
      
      it "should warn that the user must not add a vendor without permission" do
        get :new
        response.should have_selector(".rheader_highlight", 
                                :content => "Please do not add a vendor without permission")
      end
      
      it "should have a link to the gravatar site" do
        get :new
        response.should have_selector("a", :href => "http://en.gravatar.com/")
      end
      
      it "should reset the vendor_id cookie to nil" do
        get :new
        response.cookies["vendor_id"].should == nil
      end
    end
    
    
    describe "GET 'show'" do
    
      it "should successfully display the page" do
        get :show, :id => @vendor
        response.should be_success
      end
    
      it "should find the right vendor" do
        get :show, :id => @vendor
        assigns(:vendor).should == @vendor
      end
    
      it "should have the right title" do
        get :show, :id => @vendor
        response.should have_selector("title", :content => @vendor.name)
      end
      
      it "should display 'verification pending' notices if the vendor has not yet been verified" do
        @unverified_vendor = Factory(:vendor, :name => "Unverified", :country_id => @country.id,
                              :verified => false)
        @unver_representation = Factory(:representation, :user_id => @user.id, 
                                        :vendor_id => @unverified_vendor.id)
        get :show, :id => @unverified_vendor
        response.should have_selector(".warn", :content => "Awaiting email verification!")
        response.should have_selector("div#rubric", :content => "we need a response")
      end
      
      it "should not display the verification notices if the vendor has been verified" do
        @verified_vendor = Factory(:vendor, :name => "Verified", :country_id => @country.id,
                              :verified => true)
        @ver_representation = Factory(:representation, :user_id => @user.id, 
                                        :vendor_id => @verified_vendor.id)
        get :show, :id => @verified_vendor
        response.should_not have_selector(".warn", :content => "Awaiting email verification!")
        response.should_not have_selector("div#rubric", :content => "we need a response")
      end
      
      it "should include the vendor name" do
        get :show, :id => @vendor
        response.should have_selector("h1", :content => @vendor.name)
      end
      
      it "should include the vendor country" do
        get :show, :id => @vendor
        response.should have_selector("p", :content => @vendor.country.name)
      end
      
      it "should include the vendor address" do
        get :show, :id => @vendor
        response.should have_selector("p", :content => @vendor.address)
      end
      
      it "should include the vendor phone number and IDD code, if listed" do
        @phone_vendor = Factory(:vendor, :name => "Phonevendor", :country_id => @country.id,
                                         :phone => "12345")
        @phone_representation = Factory(:representation, :user_id => @user.id, 
                                        :vendor_id => @phone_vendor.id)                                 
        get :show, :id => @phone_vendor
        response.should have_selector("p", :content => @phone_vendor.phone) 
        response.should have_selector("p", :content => @country.phone_code)                                
      end
      
      it "should not include the IDD code if the phone number is unlisted" do
        get :show, :id => @vendor
        response.should_not have_selector("p", :content => @country.phone_code)
      end
      
      it "should include a link to the vendor website if listed" do
        @website_vendor = Factory(:vendor, :name => "Webvendor", :country_id => @country.id,
                          :website => "www.webvendor.info")
        @website_representation = Factory(:representation, :user_id => @user.id, 
                                        :vendor_id => @website_vendor.id)
        get :show, :id => @website_vendor   
        response.should have_selector("a",  :href => @website_vendor.website,
                                            :content => @website_vendor.website)               
      end
      
      it "should include a linked reference to the vendor's email address" do
        pending "link to a page sending email not yet designed"
      end
      
      it "should include the description if anything has been written" do
        get :show, :id => @vendor
        response.should have_selector("p", :content => @vendor.description)
      end
      
      it "should include the gravatar" do
        get :show, :id => @vendor
        response.should have_selector("h1>img", :class => "gravatar")
      end
      
      it "should have a link to the 'edit' page" do
        get :show, :id => @vendor
        response.should have_selector("a", :href => edit_business_vendor_path(@vendor),
                                           :content => "edit details")
      end
      
      it "should state that Reviews are not displayed if vendor.show_reviews is false" do
        get :show, :id => @vendor
        response.should have_selector(".loud", :content => "Not displayed")
      end
      
      it "should state that Reviews are displayed if vendor.show_reviews is true" do
        @review_vendor = Factory(:vendor, :name => "Review", :country_id => @country.id,
                                  :show_reviews => true)
        @review_representation = Factory(:representation, :user_id => @user.id, 
                                        :vendor_id => @review_vendor.id)
        get :show, :id => @review_vendor
        response.should have_selector(".loud", :content => "To turn off")
      end
      
      it "should set the vendor_id cookie to the vendor id" do
        get :show, :id => @vendor
        response.cookies["vendor_id"].should == "#{@vendor.id}"
      end
      
      it "should include a link to 'Your Colleagues'' and show the number of colleagues with record access" do
        pending "need to write links"
      end  
    end
    
    
    describe "POST 'create'" do
      
      describe "success" do
        
        before(:each) do
          @name = "Xx" 
          @attr = { :name => @name, :country_id => @country.id, 
                    :address => "London", :email => "xx@email.com" }
        end
        
        it "should add a new vendor" do
          lambda do
            post :create, :vendor => @attr
          end.should change(Vendor, :count).by(1)  
        end
        
        it "should create a new Representation record" do
          lambda do
            post :create, :vendor => @attr
          end.should change(Representation, :count).by(1) 
        end
        
        it "should include the current user and new vendor ids in the new Representation record" do
          post :create, :vendor => @attr
          @representation = Representation.find(:last)
          @representation.user_id.should == @user.id
          @representation.vendor.name.should == @name
        end
        
        it "should not mark the Vendor as verified" do
          post :create, :vendor => @attr
          @vendor = Vendor.find(:last)
          @vendor.verified.should == false
        end
        
        it "should create a verification code" do
          post :create, :vendor => @attr
          @vendor = Vendor.find(:last)
          @vendor.verification_code.length.should == 18 
        end
        
        it "should redirect to the correct vendor 'show' page" do
          post :create, :vendor => @attr
          response.should redirect_to business_vendor_path(assigns(:vendor))
        end
        
        it "should display a success message, warning that confirmation is still required" do
          post :create, :vendor => @attr
        flash[:success].should == "#{@name} has been created, and will be activated after email confirmation."
        end
        
        it "should set the vendor_id cookie to the vendor.id" do
          post :create, :vendor => @attr
          @vendor = Vendor.find(:last)
          response.cookies["vendor_id"].should == "#{@vendor.id}"
        end
        
        describe "send email for verification" do
          
          include EmailSpec::Helpers
          include EmailSpec::Matchers
          
          before(:each) do
            @attr = { :name => @name, :country_id => @country.id, 
                    :address => "London", :email => "xx@email.com", 
                    :verification_code => "abD154Hl992Dbg834L" }
          end
                    
          it "should deliver a confirmation email to the vendor's stated email address" do
            post :create, :vendor => @attr
            @vendor = Vendor.find(:last)
            @email = VendorMailer.vendor_confirmation(@vendor)
            @email.should deliver_to(@vendor.email)
          end
          
          it "should show the submitter's name in the email" do
            post :create, :vendor => @attr
            @vendor = Vendor.find(:last)
            @email = VendorMailer.vendor_confirmation(@vendor)
            @email.should have_body_text(@vendor.name)
          end
          
          it "should include the correct content in the email" do
            post :create, :vendor => @attr
            @vendor = Vendor.find(:last)
            @email = VendorMailer.vendor_confirmation(@vendor)
            @email.should have_body_text("This mail is just a precaution to check")
          end
          
          it "should have the correct subject for the email" do
            post :create, :vendor => @attr
            @vendor = Vendor.find(:last)
            @email = VendorMailer.vendor_confirmation(@vendor)
            @email.should have_subject("'Tickets for Training': Vendor Application")
          end
          
          it "should include a return address with the correct verification code" do
            post :create, :vendor => @attr
            @vendor = Vendor.find(:last)
            @email = VendorMailer.vendor_confirmation(@vendor)
            @v_code = @vendor.verification_code
            @email.should have_body_text("http://localhost:3000/confirm/#{@v_code}")
          end
        end
      end
      
      describe "failure" do
        
        before(:each) do
          @bad_attr = { :name => "", :country_id => @country.id, 
                    :address => "", :email => "xx@email" }
        end
        
        it "should not add a new vendor" do
          lambda do
            post :create, :vendor => @bad_attr
          end.should_not change(Vendor, :count)  
        end
        
        it "should not create a new Representation record" do
          lambda do
            post :create, :vendor => @bad_attr
          end.should_not change(Representation, :count) 
        end
        
        it "should not send a confirmation email to the vendor's stated email address" do
          pending "don't know how to test"
        end
        
        it "should render the vendor 'new' page" do
          post :create, :vendor => @bad_attr
          response.should render_template("business/vendors/new")
        end
        
        it "should have the right title" do
          post :create, :vendor => @bad_attr
          response.should have_selector("title", :content => "New vendor")
        end
        
        it "should display an error message showing why the entry has not been accepted" do
          post :create, :vendor => @bad_attr
          response.should have_selector("div#error_explanation", :content => "There were problems")
        end
      end
    end
    
    
    describe "GET 'edit'" do
      
      it "should be successful" do
        get :edit, :id => @vendor
        response.should be_success
      end
      
      it "should have the right title" do
        get :edit, :id => @vendor
        response.should have_selector("title", :content => "Edit vendor")
      end
      
      it "should have an entry field for 'name'" do
        get :edit, :id => @vendor
        response.should have_selector("input",  :name => "vendor[name]",
                                                :value => @vendor.name)
      end
      
      it "should show that the name field is required" do
        get :edit, :id => @vendor
        response.should have_selector("div#name", :content => "*")
      end
      
      it "should have an entry field for 'country'" do
        get :edit, :id => @vendor
        response.should have_selector("option", :value => @vendor.country.id.to_s,
                                                :selected => "selected",
                                                :content => @vendor.country.name)
      end
      
      it "should show that the country field is required" do
        get :edit, :id => @vendor
        response.should have_selector("div#country", :content => "*")
      end
      
      it "should have an entry field for 'address'" do
        get :edit, :id => @vendor
        response.should have_selector("input",  :name => "vendor[address]",
                                                :value => @vendor.address)
      end
      
      it "should show that the address field is required" do
        get :edit, :id => @vendor
        response.should have_selector("div#address", :content => "*")
      end
      
      it "should have an entry field for 'email'" do
        get :edit, :id => @vendor
        response.should have_selector("input",  :name => "vendor[email]",
                                                :value => @vendor.email)
      end
      
      it "should show that the email field is required" do
        get :edit, :id => @vendor
        response.should have_selector("div#email", :content => "*")
      end
      
      
      it "should have an entry field for 'phone'" do
        get :edit, :id => @vendor
        response.should have_selector("input",  :name => "vendor[phone]")
      end
      
      it "should have an entry field for 'website'" do
        get :edit, :id => @vendor
        response.should have_selector("input",  :name => "vendor[website]")
      end
      
      it "should have a text_area field for 'description'" do
        get :edit, :id => @vendor
        response.should have_selector("textarea",  :name => "vendor[description]",
                                                :content => @vendor.description)
      end
      
      it "should have a 'save changes' button" do
        get :edit, :id => @vendor
        response.should have_selector("input", :value => "Save changes")
      end
      
      it "should have a 'Drop changes' link to the Country 'show' form" do
        get :edit, :id => @vendor
        response.should have_selector("a", :content => "(drop changes)" )
      end
      
      it "should display the vendor's logo" do
        get :edit, :id => @vendor
        response.should have_selector(".gravatar")
      end
      
      it "should have a link to the gravatar site" do
        get :edit, :id => @vendor
        response.should have_selector("a", :href => "http://gravatar.com/emails")
      end
      
      it "should display the number of characters used as the description path is filled" do
        pending "feature to be added later"
      end
    end
    
    
    describe "PUT 'update'" do
      
      before(:each) do
        good_name = "Good Name"
        good_description = "a" * 254
        good_address = "London"
        good_email = "goodname@example.com"
        bad_name = ""
        bad_description = "a" * 256
        bad_address = ""
        bad_email = "badname.com"
        @good_attr = { :name => good_name, :country_id => @country.id, :address => good_address,
                       :email => good_email, :description => good_description }
        @bad_attr = { :name => bad_name, :country_id => @country.id, :address => bad_address,
                       :email => bad_email, :description => bad_description }
      end
      
      describe "success" do
        
        it "should update the vendor attributes" do
          put :update, :id => @vendor, :vendor => @good_attr
          vendor = assigns(:vendor)
          @vendor.reload
          @vendor.name.should == vendor.name
          @vendor.email.should == vendor.email
        end
        
        it "should display a success message" do
          put :update, :id => @vendor, :vendor => @good_attr
          flash[:success].should == "Vendor updated."
        end
        
        it "should redirect to the 'show' page" do
          put :update, :id => @vendor, :vendor => @good_attr
          response.should redirect_to business_vendor_path(@vendor)
        end
        
      end
      
      describe "failure" do
        
        it "should not update the vendor attributes" do
          put :update, :id => @vendor, :vendor => @bad_attr
          vendor = assigns(:vendor)
          @vendor.reload
          @vendor.name.should_not == vendor.name
          @vendor.email.should_not == vendor.email
        end
        
        it "should render the 'edit' template" do
          put :update, :id => @vendor, :vendor => @bad_attr
          response.should render_template("business/vendors/edit")
        end
        
        it "should display an error message" do
          put :update, :id => @vendor, :vendor => @bad_attr
          response.should have_selector("div#error_explanation", :content => "There were problems")
        end
      end
    end
  end
  
  describe "logged-in vendor-users, with vendor attributes but not associated with this vendor" do
    
    before(:each) do
      @wrong_user = Factory(:user, :email => "wrong_user@example.com", 
                            :vendor => true, :country_id => @country.id)
      @representation2 = Factory(:representation, :user_id => @wrong_user.id, :vendor_id => @vendor2.id)       
      test_log_in(@wrong_user)
    end
    
    describe "GET 'show'" do
    
      it "should not display the page" do
        get :show, :id => @vendor
        response.should_not be_success
      end
      
      it "should redirect to the business home path" do
        get :show, :id => @vendor
        response.should redirect_to business_home_path
      end
      
      it "should display a warning" do
        get :show, :id => @vendor
        flash[:error].should =~ /does not belong to you/
      end
      
    end
    
    describe "GET 'edit'" do
      
      it "should not display the page" do
        get :edit, :id => @vendor
        response.should_not be_success
      end
      
      it "should redirect to the business home path" do
        get :edit, :id => @vendor
        response.should redirect_to business_home_path
      end
      
      it "should display a warning" do
        get :edit, :id => @vendor
        flash[:error].should =~ /does not belong to you/
      end  
    end
    
    describe "PUT 'update'" do
      
      before(:each) do
        @good_name = "Good Name"
        @good_description = "a" * 254
        @good_address = "London"
        @good_email = "goodname@example.com"
        @good_attr = { :name => @good_name, :country_id => @country.id, :address => @good_address,
                       :email => @good_email, :description => @good_description }
      end

      it "should not update the vendor attributes" do
        put :update, :id => @vendor, :vendor => @good_attr
        @vendor.reload
        @vendor.name.should_not == @good_name
        @vendor.email.should_not == @good_email
      end
      
      it "should redirect to the business home path" do
        put :update, :id => @vendor, :vendor => @good_attr
        response.should redirect_to business_home_path
      end
      
      it "should display a warning" do
        put :update, :id => @vendor, :vendor => @good_attr
        flash[:error].should =~ /does not belong to you/
      end  
    end
    
    describe "DELETE 'destroy'" do
      pending
    end
  end
end
