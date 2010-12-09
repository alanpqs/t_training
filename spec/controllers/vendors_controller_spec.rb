require 'spec_helper'

describe VendorsController do

  render_views
  
  before(:each) do
    @region = Factory(:region)
    @country = Factory(:country, :region_id => @region.id)
    @user = Factory(:user, :country_id => @country.id)
    @admin = Factory( :user, :email => "admin@mail.com", :admin => true, 
                      :country_id => @country.id)
    @v_user = Factory(:user, :email => "v_user@mail.com", 
                      :vendor => true, :admin => true, :country_id => @country.id)
  end
  
  describe "PUT 'confirm'" do
    
    before(:each) do
      @v_code = "123456ABCDEFabcdef"
      @url = "http://localhost:3000/confirm/#{@v_code}"
      @vendor1 = Factory(:vendor, :verification_code => "abcdef123456ABCDEF", :country_id => @region.id)
      @vendor2 = Factory(:vendor, :name => "Second", :email => "second@mail.com",
                         :verification_code => "ABCDEF123456abcdef", :country_id => @country.id)
      @vendor3 = Factory(:vendor, :name => "Third", :email => "third@mail.com",
                      :verification_code => "123456ABCDEFabcdef", :country_id => @country.id) 
      @vendors = [@vendor1, @vendor2, @vendor3]                 
    end
      
    describe "the verification code is correct" do
      
      it "should update 'verified to true'" do
        put :confirm, :action => "confirm", :code => @v_code
        @vendor3.reload
        @vendor3.verified.should == true
      end
      
      it "should remove the verification code" do
        put :confirm, :action => "confirm", :code => @v_code
        @vendor3.reload
        @vendor3.verification_code.should == nil
      end
      
      it "should not change the verified or verification_code fields of other records" do
        put :confirm, :action => "confirm", :code => @v_code
        @vendor2.reload
        @vendor2.verification_code.should_not == nil
        @vendor2.verified.should == false
      end
      
      it "should display a success message" do
        put :confirm, :action => "confirm", :code => @v_code
        flash[:success] =~ /you can start adding your training products and services/
      end
      
      describe "redirection to the correct page" do
        
        it "should redirect logged-in vendor-users (including admins) to the business home page" do
          test_log_in(@v_user)
          put :confirm, :action => "confirm", :code => @v_code
          response.should redirect_to business_home_path
        end
        
        it "should redirect logged-in admins (unless also vendors) to the admin home page" do
          test_log_in(@admin)
          put :confirm, :action => "confirm", :code => @v_code
          response.should redirect_to admin_home_path
        end
        
        it "should direct other logged-in users to the home page" do
          test_log_in(@user)
          put :confirm, :action => "confirm", :code => @v_code
          response.should redirect_to root_path
        end
        
        it "should direct first-time users to the root-path" do
          put :confirm, :action => "confirm", :code => @v_code
          response.should redirect_to login_path
        end 
      end
    end
    
    describe "the verification code is incorrect" do
      
      before(:each) do
        @wrong_v_code = "987654abcdefABCDEF"
        @wrong_url = "http://localhost:3000/confirm/#{@wrong_v_code}"
      end
      
      it "should display a failure message" do
        put :confirm, :action => "confirm", :code => @wrong_v_code
        flash[:error].should =~ /the verification code could not be found/
      end
      
      it "should not alter the verified status if an existing verified vendor" do
        put :confirm, :action => "confirm", :code => @wrong_v_code
        @vendors.each do |vendor|
          vendor.verified.should == false
          vendor.verification_code.should_not == nil
        end
      end
      
      describe "redirection to the correct page" do
        
        it "should redirect logged-in vendor-users (including admins) to the business home page" do
          test_log_in(@v_user)
          put :confirm, :action => "confirm", :code => @wrong_v_code
          response.should redirect_to business_home_path
        end
        
        it "should redirect logged-in admins (unless also vendors) to the admin home page" do
          test_log_in(@admin)
          put :confirm, :action => "confirm", :code => @wrong_v_code
          response.should redirect_to admin_home_path
        end
        
        it "should direct other logged-in users to the home page" do
          test_log_in(@user)
          put :confirm, :action => "confirm", :code => @wrong_v_code
          response.should redirect_to root_path
        end
        
        it "should direct first-time users to the root-path" do
          put :confirm, :action => "confirm", :code => @wrong_v_code
          response.should redirect_to login_path
        end 
      end
    end
  end
end
