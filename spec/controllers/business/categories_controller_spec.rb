require 'spec_helper'

describe Business::CategoriesController do

render_views
  
  describe "for non-logged-in users" do
    
    describe "GET 'new'" do
      
      it "should not be successful" do
        pending
      end
      
      it "should redirect to the login page" do
        pending
      end
    end
    
    describe "POST 'create'" do
      
      it "should not add a new category" do
        pending
      end
    
      it "should redirect to the root path" do
        pending
      end
      
      it "should display a warning" do
        pending
      end
    end
    
  end
  
  describe "for logged-in non-vendors" do
    
    describe "GET 'new'" do
      
      it "should not be successful" do
        pending
      end
      
      it "should redirect to the user home page" do
        pending
      end
      
      it "should display a warning" do
        pending
      end
    end
    
    describe "POST 'create'" do
      
      it "should not add a new category" do
        pending
      end
    
      it "should redirect to the user home page" do
        pending
      end
      
      it "should display a warning" do
        pending
      end
    end
    
    
  end
  
  describe "for logged-in vendors" do
    
    describe "GET 'new'" do
    
      it "should be successful" do
        get :new
        response.should be_success
      end
      
      it "should have the right title" do
        pending
      end
      
      it "should display the currently selected Group" do
        pending
      end
      
      it "should have a text-box for the suggested category" do
        pending
      end
      
      it "should explain how to change to a different Group" do
        pending
      end
      
      it "should have a 'Create' button" do
        pending
      end
      
      it "should contain a list of current categories in the 'Group', including those waiting approval" do
        pending
      end
      
      it "should explain the importance of non-duplication" do
        pending
      end
      
      it "should have a 'return without changes' link" do
        pending
      end
    end

    describe "POST 'create'" do
      
      describe "success" do
      
        it "should create a new category" do
          pending
        end
      
        it "should be in the previously-selected Group" do
          pending
        end
        
        it "should not be 'authorized'" do
          pending
        end
        
        it "should redirect to the stored vendor page" do
          pending
        end
        
        it "should display a success message, explaining email notification" do
          pending
        end
      end
      
      describe "failure" do
        
        it "should not create a new category" do
          pending
        end
        
        it "should redisplay the 'new' page" do
          pending
        end
        
        it "should display an error message" do
          pending
        end
        
        it "should have the right title" do
          pending
        end
      end
    end
  end
end
