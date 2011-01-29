require 'spec_helper'

describe Business::OffersController do
  
  render_views
  
  describe "for non-logged-in users" do
    
  end
  
  describe "for logged-in non-vendors" do
    
  end
  
  describe "for the wrong logged-in user-vendor" do
    
  end
  
  describe "for the right logged-in user vendor" do
  
    describe "GET 'index'" do
      
    end
      
    describe "GET 'new'" do
      it "should be successful" do
        pending "all tests for issue still to be written"
        #get 'new'
        #response.should be_success
      end
    end
    
    describe "POST 'create'" do
      
    end
    
    describe "GET 'show'" do
      
    end
    
    describe "GET 'edit'" do
      
    end
    
    describe "PUT 'update'" do
      
    end
    
    describe "DELETE 'destroy'" do
      
    end
  end
end
