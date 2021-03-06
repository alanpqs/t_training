require 'spec_helper'

describe UsersController do
  render_views

  before(:each) do
    @region = Factory(:region)
    @country = Factory(:country, :region_id => @region.id)
    @user = Factory(:user, :country_id => @country.id)
  end
  
  describe "GET 'show'" do
    
    it "should be successful" do
      get :show, :id => @user
      response.should be_success
    end
    
    it "should find the right user" do
      get :show, :id => @user
      assigns(:user).should == @user
    end
    
    it "should have the right title" do
      get :show, :id => @user
      response.should have_selector("title", :content => @user.name)
    end
    
    it "should include the user's name" do
      get :show, :id => @user
      response.should have_selector("h1", :content => @user.name)
    end
    
    it "should have a profile image" do
      get :show, :id => @user
      response.should have_selector("h1>img", :class => "gravatar")
    end
  end

  describe "GET 'new'" do
    it "should be successful" do
      get :new
      response.should be_success
    end
    
    it "should have the right title" do
      get :new
      response.should have_selector('title', :content => "Sign Up")
    end
    
    it "should have a name field" do
      get :new
      response.should have_selector("input[name = 'user[name]'][type='text']")
    end
    
    it "should have an email field" do
      get :new
      response.should have_selector("input[name = 'user[email]'][type='text']")
    end
    
    it "should have a password field" do
      get :new
      response.should have_selector("input[name = 'user[password]'][type='password']")
    end
    
    it "should have a country selector field" do
      get :new
      response.should have_selector("select", :name => "user[country_id]",
                                                :content => "")
    end
    
    it "should have a location field" do
      get :new
      response.should have_selector("input[name = 'user[vendor]'][type='radio']",
                                    :checked => "checked",
                                    :id => "user_vendor_false")
    end
    
    it "should have a vendor select field" do
      get :new
      response.should have_selector("input[name = 'user[location]'][type='text']")
    end
    
    it "should have a password confirmation field" do
      get :new
      response.should have_selector("input[name = 'user[password_confirmation]']
                [type = 'password']")
    end
  end
  
  describe "POST 'create'" do
    
    describe "failure" do
      
      before(:each) do 
        @attr = { :name => "", :email => "", :password => "",
                  :password_confirmation => "", :location => "", :country_id => @country.id
        }
      end
      
      it "should not create a user" do 
        lambda do
          post :create, :user => @attr
        end.should_not change(User, :count)
      end
      
      it "should have the right title" do
        post :create, :user => @attr
        response.should have_selector("title", :content => "Sign Up")
      end
      
      it "should render the 'new' page" do
        post :create, :user => @attr
        response.should render_template('new')
      end
    end
    
    describe "success" do
      
      before(:each) do
        @attr = { :name => "New User", :email => "user@example.com", :country_id => @country.id,
                  :location => "Cambridge", :password => "foobar", :password_confirmation => "foobar"
        }
      end
      
      it "should create a user" do
        lambda do
          post :create, :user => @attr
        end.should change(User, :count).by(1)
      end
      
      it "should redirect to the member home page (unless marked as a vendor)" do
        post :create, :user => @attr
        response.should redirect_to member_home_path
      end
      
      it "should have a welcome message" do
        post :create, :user => @attr
        flash[:success].should =~/Welcome to Tickets for Training!/i
      end
      
      it "should log the user in" do
        post :create, :user => @attr
        controller.should be_logged_in   
      end
    end
    
    describe "when the user is also a vendor" do
      
      before(:each) do
        @vendor_attr = { :name => "Vendor User", :email => "vendir@example.com", :country_id => @country.id,
                  :location => "Cambridge", :password => "foobar", :password_confirmation => "foobar",
                  :vendor => true
        }
      end
      it "should open at the business_home page" do
        post :create, :user => @vendor_attr
        response.should redirect_to business_home_path
      end  
    end
  end
  
  
  describe "GET 'forgotten_password'" do
    
    it "should allow a user to enter an email address" do
      get :forgotten_password
      response.should have_selector("input", :name => "user[email]")
    end
    
    it "should have a submit button" do
      get :forgotten_password
      response.should have_selector(".action_round",  :type => "submit",
                                                :value => "Send request" )
    end
  end
  
  describe "PUT 'new_password'" do
    
    before(:each) do
      @email = "pwuser@mail.com"
      @unknown_email = "qzuser@mail.com"
      @attr = { :email => @email }
      @unknown_attr = { :email => @unknown_email}
      @new_password = "barbaz100"
      @pw_user = Factory(:user, :email => @email, :country_id => @country.id)
    end
    
    describe "valid email address submitted" do
        
      it "should change the user's encrypted password" do
        old_encryption = @pw_user.encrypted_password
        put :new_password, :user => @attr
        @pw_user.reload
        @pw_user.encrypted_password.should_not == old_encryption
      end
      
      describe "send email for verification" do
          
        include EmailSpec::Helpers
        include EmailSpec::Matchers
      
        it "should generate an email to the user's email address" do
          put :new_password, :user => @attr
          @user = User.find_by_email(@email)
          @email = UserMailer.new_password(@user, @new_password)
          @email.should deliver_to(@user.email)
        end
      
        it "should include the user's new password in the email" do
          put :new_password, :user => @attr
          @user = User.find_by_email(@email)
          @email = UserMailer.new_password(@user, @new_password)
          @email.should have_body_text(@new_password)
        end
        
        it "should have the correct subject for the email" do
          put :new_password, :user => @attr
          @user = User.find_by_email(@email)
          @email = UserMailer.new_password(@user, @new_password)
          @email.should have_subject("'Tickets for Training': your new password")
        end
      end
    end
    
    describe "invalid email address submitted" do
      
      it "should generate an 'unknown email' response" do
        put :new_password, :user => @unknown_attr
        flash[:error].should =~ /We couldn't find the email address/
      end
      
      it "should redisplay the forgotten password page" do
        put :new_password, :user => @unknown_attr
        response.should redirect_to forgotten_password_path
      end
    end
  end
  
  
  describe "GET 'edit'" do
    
    before(:each) do
      test_log_in(@user)
    end
    
    it "should be successful" do
      get :edit, :id => @user
      response.should be_success
    end
    
    it "should have the right title" do
      get :edit, :id => @user
      response.should have_selector("title", :content => "Edit user")
    end
    
    it "should have a country selector field" do
      get :new
      response.should have_selector("select", :name => "user[country_id]",
                                                :content => @country.name)
    end
    
    it "should have a location field" do
      get :new
      response.should have_selector("input[name = 'user[location]'][type='text']")
    end
    
    it "should have a location field" do
      get :new
      response.should have_selector("input[name = 'user[vendor]'][type='radio']",
                                    :checked => "checked",
                                    :id => "user_vendor_false")
    end
    
    it "should have a link to change the Gravatar" do
      get :edit, :id => @user
      gravatar_url = "http://gravatar.com/emails"
      response.should have_selector("a",  :href    => gravatar_url,
                                          :content => "change")
    end
  end
  
  describe "PUT 'update'" do
    
    before(:each) do
      test_log_in(@user)
    end
    
    describe "failure" do
      
      before(:each) do
        @attr = { :email => "", :name => "", :password => "",
                  :password_confirmation => ""
        }
      end
      
      it "should render the 'edit' page" do
        put :update, :id => @user, :user => @attr
        response.should render_template('edit')
      end
      
      it "should have the right title" do
        put :update, :id => @user, :user => @attr
        response.should have_selector("title", :content => "Edit user")
      end
      
      it "should not change the user's attributes" do
        put :update, :id => @user, :user => @attr
        @user.reload
        @user.name.should_not == @attr[:name]
        @user.email.should_not == @attr[:email]
      end
    end
    
    describe "success" do
      
      before(:each) do
        @attr = { :name => "New Name", :email => "newname@example.com", 
                  :country_id => @country.id, :location => "London",
                  :password => "foobar", :password_confirmation => "foobar"  }
      end
      
      it "should change the user's attributes" do
        put :update, :id => @user, :user => @attr
        @user.reload
        @user.name.should == @attr[:name]
        @user.email.should == @attr[:email]
      end
      
      it "should redirect to the user's show page" do
        put :update, :id => @user, :user => @attr
        response.should redirect_to(user_path(@user))
      end
      
      it "should have a flash message" do
        put :update, :id => @user, :user => @attr
        flash[:success].should =~ /updated/
      end
    end
  end
  
  describe "authentication of edit/update pages" do
    
    describe "for non-logged-in users" do
      
      it "should deny access to 'edit'" do
        get :edit, :id => @user
        response.should redirect_to(login_path)
      end
      
      it "should deny access to 'update'" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(login_path)
      end
    end
    
    describe "for logged-in users" do
      
      before(:each) do
        wrong_user = Factory(:user, :email => "user@example.net", :country_id => @country.id)
        test_log_in(wrong_user)
      end
      
      it "should require matching users for 'edit'" do
        get :edit, :id => @user
        response.should redirect_to(root_path)
      end
      
      it "should require matching users for 'update'" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(root_path)
      end
    end
  end
  
  describe "DELETE 'destroy'" do
    
    describe "as a non-logged-in user" do
      it "should deny access" do
        delete :destroy, :id => @user
        response.should redirect_to(login_path)
      end
    end
    
    describe "as a non-admin user" do
      it "should protect the page" do
        test_log_in(@user)
        delete :destroy, :id => @user
        response.should redirect_to(root_path)
      end
    end
    
    describe "as an admin user" do
      
      before(:each) do
        admin = Factory(:user, :email => "admin@example.com", :admin => true, :country_id => @country.id)
        test_log_in(admin)
      end
      
      it "should destroy the user" do
        lambda do
          delete :destroy, :id => @user    
        end.should change(User, :count).by(-1)
      end
      
      it "should redirect to the users page" do
        delete :destroy, :id => @user
        response.should redirect_to(users_path)
      end
    end
  end
end
