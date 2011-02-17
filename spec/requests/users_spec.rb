require 'spec_helper'

describe "Users" do
  
  before(:each) do
    @region = Factory(:region, :region => "Europe")
    @country = Factory(:country, :name => "United Kindom", :country_code => "GBR",
                                 :currency_code => "GBP", :region_id => @region.id)
  end
    
  describe "signup" do
    
    describe "failure" do
      
      it "should not make a new user" do
        lambda do
          visit signup_path
          fill_in "Name",         :with => ""
          fill_in "Email",        :with => ""
          fill_in "Country",      :with => @country.id
          fill_in "Password",     :with => ""
          fill_in "Confirmation", :with => ""
          click_button
          response.should render_template('users/new')
          response.should have_selector("div#error_explanation")
        end.should_not change(User, :count)
      end
    end
    
    describe "success" do
      
      describe "when it's an ordinary member" do
        
        it "should make a new user and redirect to the member home-page" do
        
          lambda do
            visit signup_path
            fill_in "Name",         :with => "Example User"
            fill_in "Email",        :with => "user@example.com"
            fill_in "Country",      :with => @country.id
            fill_in "Location",     :with => "London"
            fill_in "Password",     :with => "foobar"
            fill_in "Confirmation", :with => "foobar"
            click_button
            response.should have_selector("div.flash.success",
                                        :content => "Welcome")
            response.should render_template('member/pages/home')  
          end.should change(User, :count).by(1)
        end
      end
      
      describe "when it's a business user" do
        
        it "should make a new user and redirect to the business home-page" do
        
          lambda do
            visit signup_path
            fill_in "Name",         :with => "Example User"
            fill_in "Email",        :with => "user@example.com"
            fill_in "Country",      :with => @country.id
            fill_in "Location",     :with => "London"
            fill_in "Password",     :with => "foobar"
            fill_in "Confirmation", :with => "foobar"
            choose "user_vendor_true"
            
            click_button
            response.should have_selector("div.flash.success",
                                        :content => "Welcome")
            response.should render_template('business/pages/home')  
          end.should change(User, :count).by(1)
        end
      end 
    end
  end
  
  describe "log in/out" do
    
    describe "failure" do
      it "should not log a user in" do
        visit login_path
        fill_in :email,       :with => ""
        fill_in :password,    :with => ""
        click_button
        response.should have_selector("div.flash.error", :content => "Invalid")
      end
    end
    
    describe "success" do
      it "should sign a user in and out" do
        user = Factory(:user, :country_id => @country.id)
        integration_log_in(user)
        controller.should be_logged_in
        click_link "Log out"
        controller.should_not be_logged_in
      end
      
      describe "when an ordinary member" do
        
        it "should land on the member home-page" do
          user = Factory(:user, :country_id => @country.id)
          visit login_path
          fill_in :email,       :with => user.email
          fill_in :password,    :with => user.password
          click_button
          response.should render_template('member/pages/home') 
        end
        
      end
      
      describe "when a vendor-user" do
        
        it "should land on the business home-page" do
          user = Factory(:user, :country_id => @country.id, :vendor => true)
          visit login_path
          fill_in :email,       :with => user.email
          fill_in :password,    :with => user.password
          click_button
          response.should render_template('business/pages/home') 
        end
        
      end
      
      describe "when an admin-user" do
        
        it "should land on the admin home-page" do
          user = Factory(:user, :country_id => @country.id, :vendor => true, :admin => true)
          visit login_path
          fill_in :email,       :with => user.email
          fill_in :password,    :with => user.password
          click_button
          response.should render_template('admin/pages/home') 
        end
        
      end
    end
    
  end
end
