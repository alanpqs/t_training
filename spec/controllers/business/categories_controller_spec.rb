require 'spec_helper'

describe Business::CategoriesController do

render_views
  
  before(:each) do
    @region = Factory(:region)
    @country = Factory(:country, :region_id => @region.id)
    @user = Factory(:user, :country_id => @country.id, :vendor => true)
    @nonvendor_user = Factory(:user, :email => "nonvendor@example.com", :country_id => @country.id)
    @vendor = Factory(:vendor, :country_id => @country.id)
    @representation = Factory(:representation, :user_id => @user.id, :vendor_id => @vendor.id)
    @group = "Job"
    @wrong_group = "Fun"
    @category1 = Factory(:category, :user_id => @user.id, :target => @group)
    @category2 = Factory(:category, :category => "Abc", :user_id => @user.id, :target => @group,
                                    :submitted_name => "Abc", :submitted_group => @group, :authorized => true)
    @category3 = Factory(:category, :category => "Def", :user_id => @user.id, :target => @group,
                                    :submitted_name => "Def", :submitted_group => @group, :authorized => true)
    @wrong_category = Factory(:category, :category => "Jkl", :user_id => @user.id, :target => "Fun", 
                                    :submitted_name => "Abc", :submitted_group => "Fun", :authorized => true)
    @categories = [@category1, @category2, @category3]
    request.cookies["group_name"] = @group 
    
  end
  
  describe "for non-logged-in users" do
    
    describe "GET 'new'" do
      
      it "should not be successful" do
        get :new
        response.should_not be_success
      end
      
      it "should redirect to the login page" do
        get :new
        response.should redirect_to login_path
      end
    end
    
    describe "POST 'create'" do
      
      before(:each) do
        @attr = { :category => "Xyz", :target => "Job", :user_id => @user.id }
      end
      
      it "should not add a new category" do
        lambda do
          post :create, :category => @attr
        end.should_not change(Category, :count)  
      end
    
      it "should redirect to the root path" do
        post :create, :category => @attr
        response.should redirect_to root_path
      end
      
      it "should display a warning" do
        post :create, :category => @attr
        flash[:notice].should =~ /Permission denied/
      end
    end
    
  end
  
  describe "for logged-in non-vendors" do
    
    before(:each) do
      test_log_in(@nonvendor_user)
    end
    
    describe "GET 'new'" do
      
      it "should not be successful" do
        get :new
        response.should_not be_success
      end
      
      it "should redirect to the user home page" do
        get :new
        response.should redirect_to @nonvendor_user
      end
      
      it "should display a warning" do
        get :new
        flash[:notice].should =~ /If you want to sell training/
      end
    end
    
    describe "POST 'create'" do
      
      before(:each) do
        @attr = { :category => "Xyz", :target => "Job", :user_id => @nonvendor_user.id }
      end
      
      it "should not add a new category" do
        lambda do
          post :create, :category => @attr
        end.should_not change(Category, :count)  
      end
    
      it "should redirect to the root path" do
        post :create, :category => @attr
        response.should redirect_to root_path
      end
      
      it "should display a warning" do
        post :create, :category => @attr
        flash[:notice].should =~ /Permission denied/
      end
    end
  end
  
  describe "for logged-in vendors" do
    
    before(:each) do
      test_log_in(@user)
      session[:return_to] = new_vendor_resource_path(@vendor)
    end
    
    describe "GET 'new'" do
    
      it "should be successful" do
        get :new
        response.should be_success
      end
      
      it "should have the right title" do
        get :new
        response.should have_selector("title", :content => "Suggest a new category")
      end
      
      it "should display the currently selected Group" do
        get :new
        response.should have_selector(".h_tag", :content => "for the #{@group} group")
      end
      
      it "should have a text-box for the suggested category" do
        get :new
        response.should have_selector("input", :name => "category[category]",
                                               :content => "")
      end
      
      it "should have a hidden field referencing the current user's id" do
        get :new
        response.should have_selector("input", :name => "category[user_id]",
                                               :type => "hidden",
                                               :value => @user.id.to_s)
      end
      
      it "should have a hidden field for the Group" do
        get :new
        response.should have_selector("input", :name => "category[target]",
                                               :type => "hidden",
                                               :value => @group)
      end
      
      it "should have a 'Create' button" do
        get :new
        response.should have_selector("input", :type => "submit",
                                               :value => "Send your suggestion")
      end
      
      it "should contain a list of current categories in the 'Group', including those waiting approval" do
        get :new
        @categories.each do |category|
          response.should have_selector("li", :content => category.category)
        end  
      end
      
      it "should italicize unapproved categories in the current category list" do
        get :new
        response.should have_selector("i", :content => @category1.category)  
      end 
      
      it "should not include categories from other groups in the list" do
        get :new
        response.should_not have_selector("li", :content => @wrong_category.category)
      end
      
      it "should have a 'return without changes' link" do
        get :new
        response.should have_selector("a",  :href => new_vendor_resource_path(@vendor),
                                            :content => "no suggestions - back to previous form") 
      end
    end

    describe "POST 'create'" do
      
      before(:each) do
        @good_attr = { :category => "Xyz", :target => "Job", :user_id => @user.id }
        @bad_attr =  { :category => "", :target => "Job", :user_id => @user.id }
      end
      
      describe "success" do
      
        it "should create a new category" do
          lambda do
            post :create, :category => @good_attr
          end.should change(Category, :count).by(1)  
        end
      
        it "should redirect to the stored resource page" do
          post :create, :category => @good_attr
          response.should redirect_to new_vendor_resource_path(@vendor)
        end
        
        it "should display a success message, explaining email notification" do
         post :create, :category => @good_attr
         flash[:success].should =~ /We'll respond soon by email/
        end
        
        it "should have the right attributes" do
          post :create, :category => @good_attr
          @new_category = Category.find(:last)
          @new_category.target.should == @group
          @new_category.submitted_name.should == @new_category.category
          @new_category.submitted_group.should == @new_category.target
          @new_category.user_id.should == @user.id
          @new_category.authorized.should == false
        end
      end
      
      describe "failure" do
        
        it "should not create a new category" do
          lambda do
            post :create, :category => @bad_attr
          end.should_not change(Category, :count)  
        end
        
        it "should redisplay the 'new' page" do
          post :create, :category => @bad_attr
          response.should render_template("new")
        end
        
        it "should display an error message" do
          post :create, :category => @bad_attr
          response.should have_selector("div#error_explanation", :content => "There were problems")
        end
        
        it "should have the right title" do
          post :create, :category => @bad_attr
          response.should have_selector("title", :content => "Suggest a new category")
        end
      end
    end
  end
end
