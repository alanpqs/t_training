require 'spec_helper'

describe Admin::CategoriesController do

  render_views
  
  describe "For non-logged-in users" do
  
    describe "GET 'index'" do
      
      it "should not be successful" do
        get :index
        response.should_not be_success
      end
      
      it "should redirect to the login page" do
        get :index
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
    
  
    
  end
  
  
  describe "For logged-in non-admins" do
  
    before(:each) do
      @aim = 1
      @aim_name = "#{Category::AIM_TYPES[@aim]}"
      @user = Factory(:user)
      test_log_in(@user)
    end
    
    describe "GET 'index'" do
      
      it "should not be successful" do
        get :index, :id => @aim_name
        response.should_not be_success
      end
      
      it "should redirect to the home page" do
        get :index
        response.should redirect_to(root_path)
      end
    end
    
    describe "GET 'new'" do
      
      it "should not be successful" do
        get :new
        response.should_not be_success
      end
      
      it "should redirect to the home page" do
        get :new
        response.should redirect_to(root_path)
      end
      
    end
  end
  
  
  describe "For logged-in admins" do
    
    before(:each) do
      @aim = 1
      @aim_name = "#{Category::AIM_TYPES[@aim]}"
      @user = Factory(:user, :admin => true)
      test_log_in(@user)
    end
    
    describe "GET 'index'" do
      
      it "should be successful" do
        get :index, :id => @aim_name
        response.should be_success
      end
      
      it "should have the right title" do
        get :index, :id => @aim_name
        response.should have_selector(:title, 
                    :content => "Training categories => #{@aim_name}" )
      end
             
      it "should include all authorized categories for the selected group" do
        pending
      end
      
      #note: USERS will only see Authorized categories.
      
      it "should include a field showing whether the category has been authorized or not" do
        pending
      end
      
      it "should include a delete option for all categories that have never been used" do
        pending
      end
      
      it "should exclude the delete option for categories that are linked to training" do
        pending
      end
      
      it "should include a link to the 'edit' form for each category in the list" do
        pending
      end
      
      it "should have a 'New category' button including the category type in the label" do
        get :index, :id => @aim_name
        response.should have_selector("a",   :href     => "/admin/categories/new?id=#{@aim_name}",
                                             :content  => "New category - #{@aim_name} grouping")
      end
    end
    
    describe "GET 'new'" do
      
      before(:each) do
        @attr = { :id => @aim_name, :user_id => @user.id }
      end
      
      it "should be successful" do
        get :new, @attr
        response.should be_success
      end
      
      it "should have the right title" do
        get :new, @attr
        response.should have_selector(:title, 
                    :content => "New #{@aim_name} category" )
      end
      
      it "should have a visible, editable text-box for the new category" do
        get :new, @attr
        response.should have_selector("input",  :name => "category[category]",
                                                :content => "")
      end
      
      it "should have a hidden text-box with the correct grouping pre-set" do
        get :new, @attr
        response.should have_selector("input",  :name => "category[aim]",
                                                :type => "hidden",
                                                :value => @aim.to_s)
      end
      
      it "should have a hidden text-box with the current user's user_id pre-set" do
        get :new, @attr
        response.should have_selector("input",  :name => "category[user_id]",
                                                :type => "hidden",
                                                :value => @user.id.to_s)
      end
      
      it "should have a hidden text-box for 'authorized', pre-set to false" do
        get :new, @attr
        response.should have_selector("input",  :name => "category[authorized]",
                                                :type => "hidden",
                                                :value => "false")
      end
      
      it "should have a return link to the 'index' page for the grouping" do
        get :new, @attr
        response.should have_selector("a",      :href => "#{admin_categories_path}?id=#{@aim_name}",
                                                :content => "check the current list")
      end
      
      it "should have a submit button" do
        get :new, @attr
        response.should have_selector("input", :value => "Create")
      end  
    end
    
    describe "POST 'create'" do
      
      before(:each) do
        @attr_blank = { :category => "", :aim => @aim, :user_id => @user.id }
      end
        
      describe "failure" do
        
        it "should not create a new Category record" do
          lambda do
            post :create, :category => @attr_blank
          end.should_not change(Country, :count)  
        end
        
        it "should render the 'new' page again" do
          post :create, :category => @attr_blank
          response.should render_template("admin/categories/new")
        end
        
        it "should have the right title" do
          post :create, :category => @attr_blank
          response.should have_selector("title", :content => "New #{@aim_name} category")
        end
        
        it "should generate an appropriate error message" do
          post :create, :category => @attr_blank
          response.should have_selector("div#error_explanation", :content => "There were problems")
        end
      end
      
      describe "success" do
        
        it "should create a new Category record" do
        
        end
      
        it "should save the record in the correct Category group" do
          
        end
        
        it "should include the user_id in the saved record" do
      
        end
        
        it "should send the creator a thank you message" do
          
        end
        
        it "should return the user to the correct category group listing" do
          
        end
      end
    end
  end
    

end
