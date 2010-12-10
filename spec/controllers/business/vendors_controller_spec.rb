require 'spec_helper'

describe Business::VendorsController do

  render_views
  
  before(:each) do
    @region = Factory(:region)
    @country = Factory(:country, :region_id => @region.id)
    @vendor = Factory(:vendor, :country_id => @country.id, :description => "Great trainer")
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
    
  end
  
  describe "logged-in non-vendors" do
    
    before(:each) do
      @user = Factory(:user, :country_id => @country.id)
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
      
      it "should redirect to the root page" do
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
  end
  
  describe "logged-in vendors" do
  
    before(:each) do
      @user = Factory(:user, :vendor => true, :country_id => @country.id)
      test_log_in(@user)
    end
    
    describe "GET 'index'" do
      it "should be successful" do
        get :index
        response.should be_success
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
        response.should have_selector("input",  :name => "vendor[name]",
                                                :content => "")
      end
      
      it "should show that the name field is required" do
        get :new
        response.should have_selector("div#name", :content => "*")
      end
      
      it "should have an entry field for 'country', preset to the user's country" do
        get :new
        response.should have_selector("select", :name => "vendor[country_id]",
                                                :content => @user.country.name)
      end
      
      it "should show that the country field is required" do
        get :new
        response.should have_selector("div#country", :content => "*")
      end
      
      it "should have an empty entry field for 'address'" do
        get :new
        response.should have_selector("input",  :name => "vendor[address]",
                                                :content => "")
      end
      
      it "should show that the address field is required" do
        get :new
        response.should have_selector("div#address", :content => "*")
      end
      
      it "should have an empty entry field for 'email'" do
        get :new
        response.should have_selector("input",  :name => "vendor[email]",
                                                :content => "")
      end
      
      it "should show that the email field is required" do
        get :new
        response.should have_selector("div#email", :content => "*")
      end
      
      
      it "should have an empty entry field for 'phone'" do
        get :new
        response.should have_selector("input",  :name => "vendor[phone]",
                                                :content => "")
      end
      
      it "should have an empty entry field for 'website'" do
        get :new
        response.should have_selector("input",  :name => "vendor[website]",
                                                :content => "")
      end
      
      it "should have an empty text_area field for 'description'" do
        get :new
        response.should have_selector("textarea",  :name => "vendor[description]",
                                                :content => "")
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
        get :show, :id => @unverified_vendor
        response.should have_selector(".warn", :content => "Awaiting email verification!")
        response.should have_selector("div#rubric", :content => "we need a response")
      end
      
      it "should not display the verification notices if the vendor has been verified" do
        @verified_vendor = Factory(:vendor, :name => "Verified", :country_id => @country.id,
                              :verified => true)
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
  end
end
