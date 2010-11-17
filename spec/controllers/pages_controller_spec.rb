require 'spec_helper'

describe PagesController do
  render_views

  before(:each) do
    @base_title = "Tickets for Training"
  end

  describe "GET 'home'" do
    it "should be successful" do
      get 'home'
      response.should be_success
    end
    
    it "should have the right title" do
      get 'home'
      response.should have_selector("title",
              :content => @base_title + " | Home"
      )
    end
  end

  describe "GET 'why_register'" do
    it "should be successful" do
      get 'why_register'
      response.should be_success
    end
    
    it "should have the right title" do
      get 'why_register'
      response.should have_selector("title",
              :content => @base_title + " | Why Register"
      )
    end
    
    it "should redirect to the 'Find training' page" do
      #Add detail 
    end
  end
  
  describe "GET 'about'" do
    it "should be successful" do
      get 'about'
      response.should be_success
    end
    
    it "should have the right title" do
      get 'about'
      response.should have_selector("title",
              :content => @base_title + " | About"
      )
    end
  end
  
  describe "GET 'categories_admin'" do
    
    describe "for non-logged-in users" do
    
      it "should not be available" do
        get :categories_admin
        response.should_not be_success
      end
      
      it "should redirect to the log-in path" do
        get :categories_admin
        response.should redirect_to(login_path)
      end
    end
    
    describe "for logged-in non-admins" do
      
      before(:each) do
        user = Factory(:user)
        test_log_in(user)
      end
      
      it "should not be available" do
        get :categories_admin
        response.should_not be_success
      end
      
      it "should redirect to the root-path" do
        get :categories_admin
        response.should redirect_to(root_path)
      end
    end
    
    describe "for logged-in admins" do
      
      before(:each) do
        user = Factory(:user, :admin => true)
        test_log_in(user)
      end
      
      it "should be successful" do
        get :categories_admin
        response.should be_success
      end
      
      it "should have the right title" do
        get :categories_admin
        response.should have_selector(:title,     :content => "Training categories") 
      end
      
      it "should have a 'Business' link to the category index" do
        get :categories_admin
        response.should have_selector(:a,    :href => "#{categories_path}?id=0",
                                             :content => "Understanding the business")
      end
      
      it "should have a 'Job' link to the category index" do
        get :categories_admin
        response.should have_selector(:a,    :href => "#{categories_path}?id=1",
                                             :content => "Getting better at the job")
      end
      
      it "should have a 'Personal' link to the category index" do
        get :categories_admin
        response.should have_selector(:a,    :href => "#{categories_path}?id=2",
                                             :content => "Improving personal skills")
      end
      
      it "should have a 'World' link to the category index" do
        get :categories_admin
        response.should have_selector(:a,    :href => "#{categories_path}?id=3",
                                             :content => "Understanding world issues") 
      end
      
      it "should have a 'Fun' link to the category index" do
        get :categories_admin
        response.should have_selector(:a,    :href => "#{categories_path}?id=4",
                                             :content => "Having fun")
      end
    end 
  end
end
