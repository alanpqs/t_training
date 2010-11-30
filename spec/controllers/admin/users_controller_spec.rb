require 'spec_helper'

describe Admin::UsersController do

  render_views
  
  before(:each) do
    @region = Factory(:region)
    @country = Factory(:country, :region_id => @region.id)
    @user = Factory(:user, :country_id => @country.id)
    
  end
  
  describe "for non-logged-in users" do
    
    #before(:each) do
    #  @user = Factory(:user)
    #end
    
    describe "GET 'index'" do
      
      it "should deny access" do
        get :index
        response.should_not be_success
        response.should redirect_to(login_path)
      end
    end
    
    describe "GET 'show'" do
      
      it "should not be successful" do
        get :show, :id => @user
        response.should_not be_success
        response.should redirect_to(login_path)
      end
    end
    
    describe "GET 'edit'" do
      
      it "should not be successful" do
        get :edit, :id => @user
        response.should_not be_success
        response.should redirect_to(login_path)
      end  
    end
    
    describe "PUT 'update'" do
      
      it "should deny access to 'update'" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(login_path)
      end
    end
    
    describe "DELETE 'destroy'" do
      
      it "should deny access" do
        delete :destroy, :id => @user
        response.should redirect_to(login_path)
      end
      
      it "should not change the number of users" do
        lambda do
          delete :destroy, :id => @user
        end.should_not change(User, :count)
      end
    end
    
  end
  
  describe "for logged-in non-admins" do
    
    before(:each) do
      #@user = Factory(:user)
      test_log_in(@user)
    end
    
    describe "GET 'index'" do
      
      it "should deny access" do
        get :index
        response.should_not be_success
        response.should redirect_to(root_path)
      end
    end
    
    describe "GET 'show'" do
      
      it "should not be successful" do
        get :show, :id => @user
        response.should_not be_success
        response.should redirect_to(root_path)
      end
    end
    
    describe "GET 'edit'" do
      
      it "should not be successful" do
        get :edit, :id => @user
        response.should_not be_success
        response.should redirect_to(root_path)
      end  
    end
    
    describe "PUT 'update'" do
      
      it "should deny access to 'update'" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(root_path)
      end
    end
    
    describe "DELETE 'destroy'" do
      
      it "should deny access" do
        delete :destroy, :id => @user
        response.should redirect_to(root_path)
      end
      
      it "should not change the number of users" do
        lambda do
          delete :destroy, :id => @user
        end.should_not change(User, :count)
      end
    end
    
  end
  
  describe "for logged-in admins" do
    
    before(:each) do
      @admin = Factory(:user, :email => "admin@example.com", :admin => true, :country_id => @country.id)
      @second =  Factory( :user, :name => "Second", 
                          :email => "another@example.com", :country_id => @country.id)
      @third =   Factory(:user, :name => "Third", 
                          :email => "another@example.net", :country_id => @country.id)
      test_log_in(@admin)
    end
      
    describe "GET 'index'" do
      
      before(:each) do
        
        @users = [@admin, @second, @third]
        30.times do
          @users << Factory(:user, :country_id => @country.id, :email => Factory.next(:email))
        end
      end
      
      it "should be successful" do
        get :index
        response.should be_success
      end
      
      it "should have the right title" do
        get :index
        response.should have_selector("title", :content => "All users")
      end
      
      it "should have an element for each user" do
        get :index
        @users[0..2].each do |user|
          response.should have_selector("li", :content => user.name)
        end
      end
      
      it "should have a link to the 'show' page for each user" do
        get :index
        @users[0..2].each do |user|
          response.should have_selector("a",  :href => admin_user_path(user),
                                              :content => user.name)
        end
      end
      
      it "should paginate users" do
        get :index
        response.should have_selector("div.pagination")
        response.should have_selector("span.disabled", :content => "Previous")
        response.should have_selector("a",    :href => "/admin/users?page=2",
                                                :content => "2")
        response.should have_selector("a",    :href => "/admin/users?page=2",
                                                :content => "Next")
      end            
    end
    
    describe "GET 'show'" do
    
      it "should be successful" do
        get :show, :id => @second
        response.should be_success
      end
    
      it "should find the right user" do
        get :show, :id => @second
        assigns(:user).should == @second
      end
    
      it "should have the right title" do
        get :show, :id => @second
        response.should have_selector("title", :content => @second.name)
      end
    
      it "should include the user's name" do
        get :show, :id => @second
        response.should have_selector("h1", :content => @second.name)
      end
    
      it "should have a profile image" do
        get :show, :id => @second
        response.should have_selector("h1>img", :class => "gravatar")
      end  
      
    end
  
    describe "GET 'edit'" do
    
      it "should be successful" do
        get :edit, :id => @second
        response.should be_success
      end
    
      it "should have the right title" do
        get :edit, :id => @second
        response.should have_selector("title", :content => "Edit user")
      end
    
      it "should have a link to change the Gravatar" do
        get :edit, :id => @second
        gravatar_url = "http://gravatar.com/emails"
        response.should have_selector("a",  :href    => gravatar_url,
                                          :content => "change")
      end
    end
    
    describe "PUT 'update'" do
      
      describe "failure" do
      
        before(:each) do
          @attr = { :email => "", :name => "", :password => "",
                    :password_confirmation => ""
          }
        end
      
        it "should render the 'edit' page" do
          put :update, :id => @second, :user => @attr
          response.should render_template('admin/users/edit')
        end
      
        it "should have the right title" do
          put :update, :id => @second, :user => @attr
          response.should have_selector("title", :content => "Edit user")
        end
      
        it "should not change the user's attributes" do
          put :update, :id => @second, :user => @attr
          @second.reload
          @second.name.should_not == @attr[:name]
          @second.email.should_not == @attr[:email]
        end
      end
    
      describe "success" do
      
        before(:each) do
          @attr = { :name => "New Name", :email => "newname@example.com",
                    :password => "barbaz", :password_confirmation => "barbaz", :country_id => @country.id
          }
        end
      
        it "should change the user's attributes" do
          put :update, :id => @second, :user => @attr
          @second.reload
          @second.name.should == @attr[:name]
          @second.email.should == @attr[:email]
        end
      
        it "should redirect to the user's show page" do
          put :update, :id => @second, :user => @attr
          response.should redirect_to(admin_user_path(@second))
        end
      
        it "should have a flash message" do
          put :update, :id => @second, :user => @attr
          flash[:success].should =~ /updated/
        end
      end  
    end
    
    describe "DELETE 'destroy'" do
      
      describe "failure, and mark instead as inactive" do
        
        it "should not delete the current user" do
          lambda do
            delete :destroy, :id => @admin
            flash[:notice].should =~ /You cannot delete your own record./
            response.should redirect_to(admin_users_path)  
          end.should_not change(User, :count)
        end
        
        it "should not delete a user with a history of ticket activity" do
          pending 
        end
        
      end
      
      describe "success" do
            
        it "should destroy the user" do
          lambda do
            delete :destroy, :id => @second    
          end.should change(User, :count).by(-1)
        end
      
        it "should redirect to the users 'index' page" do
          delete :destroy, :id => @third
          response.should redirect_to(admin_users_path)
        end
      end
    end
  end
end
  
  
  
  
  
 
