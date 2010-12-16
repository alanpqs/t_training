require 'spec_helper'

describe Admin::MediaController do

  render_views

  before(:each) do
    @region = Factory(:region)
    @country = Factory(:country, :region_id => @region.id)
    @user = Factory(:user, :country_id => @country.id)
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
        get :new
        response.should redirect_to login_path
      end
    end
    
    describe "POST 'create'" do
      
      before(:each) do
        @attr = { :medium => "Xyz", :user_id => @user.id }
      end
      
      it "should not create a new medium" do
        lambda do
          post :create, :medium => @attr
        end.should_not change(Medium, :count)
      end
      
      it "should redirect to the root path" do
        post :create, :medium => @attr
        response.should redirect_to root_path
      end
      
    end
    
    describe "GET 'edit'" do
      
      before(:each) do
        @authorized_medium = Factory(:medium, :authorized => true, :user_id => @user.id)
      end
      
      it "should not be successful" do
        get :edit, :id => @authorized_medium
        response.should_not be_success
      end
      
      it "should redirect to the login path" do
        get :edit, :id => @authorized_medium
        response.should redirect_to login_path
      end
    end
    
    describe "PUT 'update'" do
      
      before(:each) do
        @authorized_medium = Factory(:medium, :authorized => true, :user_id => @user.id)
        @attr = { :medium => "New" }
      end
      
      it "should not change the medium's attributes" do
        put :update, :id => @authorized_medium, :medium => @attr
        #medium = assigns(:medium)
        @authorized_medium.reload
        @authorized_medium.medium.should_not == "New"
      end
      
      it "should redirect to the root path" do
        put :update, :id => @authorized_medium, :medium => @attr
        response.should redirect_to root_path
      end
    end
    
    describe "DELETE 'destroy'" do
      
      before(:each) do
        @rejected_medium = Factory( :medium, :user_id => @user.id, 
                                    :authorized => false, :rejection_message => "Rejected")
      end
      
      it "should be redirect to the login path" do
        delete :destroy, :id => @rejected_medium
        response.should redirect_to(login_path)
      end
      
      it "should not change the total of media" do
        lambda do
          delete :destroy, :id => @rejected_medium
        end.should_not change(Medium, :count)
      end
    end 
  end
  
  describe "for logged-in non-admins" do
    
    before(:each) do
      test_log_in(@user)
    end
    
    describe "GET 'index'" do
      
      it "should not be successful" do
        get :index
        response.should_not be_success
      end
      
      it "should redirect to the root path" do
        get :index
        response.should redirect_to root_path
      end
    end
    
    describe "GET 'new'" do
      
      it "should not be successful" do
        get :new
        response.should_not be_success
      end
      
      it "should redirect to the root path" do
        get :new
        response.should redirect_to root_path
      end
    end
    
    describe "POST 'create'" do
      
      before(:each) do
        @attr = { :medium => "Xyz", :user_id => @user.id }
      end
      
      it "should not create a new medium" do
        lambda do
          post :create, :medium => @attr
        end.should_not change(Medium, :count)
      end
      
      it "should redirect to the root path" do
        post :create, :medium => @attr
        response.should redirect_to root_path
      end
      
    end
    
    describe "GET 'edit'" do
      
      before(:each) do
        @authorized_medium = Factory(:medium, :authorized => true, :user_id => @user.id)
      end
      
      it "should not be successful" do
        get :edit, :id => @authorized_medium
        response.should_not be_success
      end
      
      it "should redirect to the root path" do
        get :edit, :id => @authorized_medium
        response.should redirect_to root_path
      end
      
    end
    
    describe "PUT 'update'" do
      
      before(:each) do
        @authorized_medium = Factory(:medium, :authorized => true, :user_id => @user.id)
        @attr = { :medium => "New" }
      end
      
      it "should not change the medium's attributes" do
        put :update, :id => @authorized_medium, :medium => @attr
        #medium = assigns(:medium)
        @authorized_medium.reload
        @authorized_medium.medium.should_not == "New"
      end
      
      it "should redirect to the root path" do
        put :update, :id => @authorized_medium, :medium => @attr
        response.should redirect_to root_path
      end
    end
    
    describe "DELETE 'destroy'" do
      
      before(:each) do
        @rejected_medium = Factory( :medium, :user_id => @user.id, 
                                    :authorized => false, :rejection_message => "Rejected")
      end
      
      it "should be redirect to the root path" do
        delete :destroy, :id => @rejected_medium
        response.should redirect_to(root_path)
      end
      
      it "should not change the total of media" do
        lambda do
          delete :destroy, :id => @rejected_medium
        end.should_not change(Medium, :count)
      end
    end 
  end
  
  describe "for logged-in admins" do

    before(:each) do
      @admin = Factory(:user, :name => "Admin", :email => "admin@example.com", 
                              :admin => true, :country_id => @country.id)
      test_log_in(@admin)
      @medium1 = Factory(:medium, :user_id => @admin.id)
      @medium2 = Factory(:medium, :medium => "Def", :user_id => @admin.id)
      @rejected_medium = Factory(:medium, :medium => "jkl", :user_id => @admin.id, 
                                 :authorized => false, :rejection_message => "No good")
      @authorized_medium = Factory(:medium, :medium => "mno", :user_id => @admin.id, :authorized => true)
      @media = [@medium1, @medium2, @rejected_medium, @authorized_medium]
    end
    
    describe "GET 'index'" do
      
      it "should be successful given valid attributes" do
        get :index
        response.should be_success
      end
      
      it "should have the right title" do
        get :index
        response.should have_selector("title", :content => "Training media")
      end
      
      it "should have an element for each medium" do
        get :index
        @media.each do |medium|
          response.should have_selector("li", :content => medium.medium)
        end
      end
      
      it "should have a 'New medium' button" do
        get :index
        response.should have_selector("a",    :href     => "/admin/media/new",
                                                :content  => "New medium")
      end
      
      
      describe "for authorized media" do
        
        before(:each) do
          @media_authorized = [@authorized_medium]
          @media = []
        end
        
        it "should have a link to the edit form" do
          get :index
          @media_authorized.each do |medium|
            response.should have_selector("a", :href => edit_admin_medium_path(medium))
          end
        end
        
        it "should show the number of training resources associated with this medium" do
          pending "till training resources are added"
        end
      
        it "should have a 'delete' control for a medium which is not associated with a training resource" do
          pending "till training resources are added"
        end
      
        it "should not have a 'delete' control for a medium which is associated with a training resource" do
          pending "till training resources are added"
        end
      end
      
      describe "for unauthorized media" do
        
        it "should have a link to the 'authorize_media' edit form" do
          get :index
          @media[0..1].each do |medium|
            response.should have_selector("a", :href => edit_admin_authorize_medium_path(medium))
          end
        end
        
        it "should display 'Authorization pending'" do
          get :index
          @media[0..1].each do |medium|
            response.should have_selector(".loud", :content => "Authorization pending")
          end
        end
      end
      
      describe "for rejected media" do
        
        before(:each) do        
          @media_rejected = [@rejected_medium]
          @media = []
        end
        
        it "should not have a link to the edit form" do
          get :index
          @media_rejected.each do |medium|
            response.should_not have_selector("a", :href => edit_admin_medium_path(medium))
          end
        end
      
        it "should not have a link to the 'authorize_media' edit form" do
          
          get :index
          @media_rejected.each do |medium|
            response.should_not have_selector("a", :href => edit_admin_authorize_medium_path(medium))
          end
        end
        
        it "should display a delete control" do
          get :index
          @media_rejected.each do |medium|
            response.should have_selector("a", :href => "/admin/media/#{medium.id}",
                                               :content => "- now delete")
          end
        end
      
      end
    end

    describe "GET 'new'" do
      it "should be successful" do
        get :new
        response.should be_success
      end
      
      it "should have the right title" do
        get :new
        response.should have_selector("title", :content => "New training medium")
      end
      
      it "should have an empty input box for the media name" do
        get :new
        response.should have_selector("input", :name => "medium[medium]")
      end
      
      it "should have a hidden input box for the user_id containing the current user's id" do
        get :new
        response.should have_selector("input", :name => "medium[user_id]",
                                               :value => @admin.id.to_s,
                                               :type => "hidden")
      end
      
      it "should have a 'Create' button" do
        get :new
        response.should have_selector("input", :value => "Create")
      end
      
      it "should not have a 'Drop changes' link" do
        get :new
        response.should_not have_selector("a", :content => "(drop changes)" )
      end
    end


    describe "POST 'create'" do
      
      before(:each) do
        @bad_attr = { :medium => "", :user_id => @admin.id }
        @good_attr = { :medium => "Xyz", :user_id => @admin.id }
      end
      
      describe "success" do
        
        it "should add a new medium" do
          lambda do
            post :create, :medium => @good_attr
          end.should change(Medium, :count).by(1)
        end
        
        it "should redirect to the media index path" do
          post :create, :medium => @good_attr
          response.should redirect_to admin_media_path
        end
        
        it "should have a success message" do
          post :create, :medium => @good_attr
          flash[:success].should =~ /successfully created/
        end
        
      end
      
      describe "failure" do
        
        it "should not add a new medium" do
          lambda do
            post :create, :medium => @bad_attr
          end.should_not change(Medium, :count)
        end
        
        it "should render the 'new' page again" do
          post :create, :medium => @bad_attr
          response.should render_template("admin/media/new")
        end
        
        it "should have the right title" do
          post :create, :medium => @bad_attr
          response.should have_selector("title", :content => "New training medium")
        end
        
        it "should display a failure message" do
          post :create, :medium => @bad_attr
          response.should have_selector("div#error_explanation", :content => "There were problems")
        end
      end
      
    end
    
    
    describe "GET 'edit'" do
      
      it "should be successful" do
        get :edit, :id => @authorized_medium
        response.should be_success
      end
      
      it "should have the right title" do
        get :edit, :id => @authorized_medium
        response.should have_selector("title", :content => "Modify training medium")
      end
      
      it "should have a correctly-filled input box for the media name" do
        get :edit, :id => @authorized_medium
        response.should have_selector("input", :name => "medium[medium]",
                                               :value => @authorized_medium.medium)
      end
      
      it "should have an 'Confirm change' button" do
        get :edit, :id => @authorized_medium
        response.should have_selector("input", :value => "Confirm change")
      end
      
      it "should have a 'Drop changes' link" do
        get :edit, :id => @authorized_medium
        response.should have_selector("a", :content => "(drop changes)" )
      end
    end
    
    describe "PUT 'update'" do
      
      describe "success" do
        
        before(:each) do
          @attr = { :medium => "New" }  
        end
        
        it "should successfully change the medium's attributes" do
          put :update, :id => @authorized_medium, :medium => @attr
          medium = assigns(:medium)
          @authorized_medium.reload
          @authorized_medium.medium.should == medium.medium
        end
        
        it "should redirect to the index page" do
          put :update, :id => @authorized_medium, :medium => @attr
          response.should redirect_to admin_media_path
        end
        
        it "should display a success message" do
          put :update, :id => @authorized_medium, :medium => @attr
          flash[:success].should =~ /has been successfully changed/
        end
      end
      
      describe "failure" do
        
        before(:each) do
          @attr = { :medium => "" }  
        end
        
        it "should not change the medium's attributes" do
          put :update, :id => @authorized_medium, :medium => @attr
          medium = assigns(:medium)
          @authorized_medium.reload
          @authorized_medium.medium.should_not == medium.medium
        end
        
        it "should render the edit page again" do
          put :update, :id => @authorized_medium, :medium => @attr
          response.should render_template("edit")
        end
        
        it "should have the correct title" do
          put :update, :id => @authorized_medium, :medium => @attr
          response.should have_selector("title", :content => "Modify training medium")
        end
        
        it "should display an error message" do
          put :update, :id => @authorized_medium, :medium => @attr
          response.should have_selector("div#error_explanation", :content => "There were problems")
        end
      end
    end
    
    describe "DELETE 'destroy'" do
      
      describe "success" do
        
        it "should decrease the number of media by one" do
          lambda do
            delete :destroy, :id => @rejected_medium
          end.should change(Medium, :count).by(-1)
        end
        
        it "should redirect to the media index page" do
          delete :destroy, :id => @rejected_medium
          response.should redirect_to admin_media_path
        end
        
        it "should display a message showing what has been deleted" do
          delete :destroy, :id => @rejected_medium
          flash[:success].should == "'#{@rejected_medium.medium}' deleted"
        end
      end
      
      describe "failure" do
        
        it "should not change the number of media" do
          lambda do
            delete :destroy, :id => @authorized_medium
          end.should_not change(Medium, :count)
        end
        
        it "should redirect to the media index page" do
          delete :destroy, :id => @authorized_medium
          response.should redirect_to admin_media_path
        end
        
        it "should display a failure notice" do
          delete :destroy, :id => @authorized_medium
          flash[:error].should =~ /cannot be deleted/
        end
      end
    end
  end

end
