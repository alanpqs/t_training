require 'spec_helper'

describe Admin::AuthorizeMediaController do

  render_views
  
  before(:each) do
    @region = Factory(:region)
    @country = Factory(:country, :region_id => @region.id)
    @user = Factory(:user, :country_id => @country.id)
    @admin = Factory(:user, :email => "admin@user.com", :admin => true, :country_id => @country.id)
    @medium = Factory(:medium, :user_id => @admin.id)
  end
  
  describe "for non-logged-in users" do
    
    describe "GET 'edit'" do
      
      it "should not be successful" do
        get 'edit', :id => @medium
        response.should_not be_success
      end
      
      it "should redirect to the login page" do
        get 'edit', :id => @medium
        response.should redirect_to login_path
      end
    end
    
    describe "PUT update" do
      
      before(:each) do
        @attr = { :authorized => true }
      end
      
      it "should not change the medium's attributes" do
        put :update, :id => @medium, :medium => @attr
        @medium.reload
        @medium.authorized.should == false
      end
      
      it "should redirect to the root_path" do
        put :update, :id => @medium, :medium => @attr
        response.should redirect_to root_path
      end
    end
    
  end
  
  
  describe "for logged-in non-admins" do
    
    before(:each) do
      test_log_in(@user)
    end
    
    describe "GET 'edit'" do
      
      it "should not be successful" do
        get 'edit', :id => @medium
        response.should_not be_success
      end
      
      it "should redirect to the root page" do
        get 'edit', :id => @medium
        response.should redirect_to root_path
      end
    end
    
    describe "PUT update" do
      
      before(:each) do
        @attr = { :authorized => true }
      end
      
      it "should not change the medium's attributes" do
        put :update, :id => @medium, :medium => @attr
        @medium.reload
        @medium.authorized.should == false
      end
      
      it "should redirect to the root_path" do
        put :update, :id => @medium, :medium => @attr
        response.should redirect_to root_path
      end
    end
    
  end
  
  describe "for logged-in admins" do
    
    before(:each) do
      test_log_in(@admin)
      
    end
    
    describe "GET 'edit'" do
      it "should be successful" do
        get 'edit', :id => @medium
        response.should be_success
      end
      
      it "should have the right title" do
        get :edit, :id => @medium
        response.should have_selector("title", :content => "Authorize training format")
      end
      
      it "should have a correctly-filled input box for the media name" do
        get :edit, :id => @medium
        response.should have_selector("input", :name => "medium[medium]",
                                               :value => @medium.medium)
      end
      
      it "should have an Authorized check-box" do
        get :edit, :id => @medium
        response.should have_selector("input", :name => "medium[authorized]",
                                               :type => "checkbox")
      end
      
      it "should show the creator's name" do
        get :edit, :id => @medium
        response.should have_selector("p.notes", 
         :content => @medium.user.name)
      end
    
      it "should show when the category was submitted" do
        get :edit, :id => @medium
        response.should have_selector("p.notes", 
         :content => @medium.created_at.strftime('%d-%b-%Y'))
      end
      
      it "should have a 'rejection' text area" do
        get :edit, :id => @medium
        response.should have_selector("textarea", :name => "medium[rejection_message]")
      end
      
      it "should have an 'Confirm changes' button" do
        get :edit, :id => @medium
        response.should have_selector("input", :value => "Confirm changes")
      end
      
      it "should have a 'Drop changes' link" do
        get :edit, :id => @medium
        response.should have_selector("a", :content => "(drop changes)" )
      end
      
    end
    
    describe "PUT 'update'" do
     
      describe "success" do
        
        describe "when the entry is authorized with no other changes" do
          
          before(:each) do
            @attr = { :authorized => true}
          end
          
          it "should change the medium's attributes" do
            put :update, :id => @medium, :medium => @attr
            medium = assigns(:medium)
            @medium.reload
            @medium.authorized.should == medium.authorized
          end
          
          it "should redirect to the admin_media_path" do
            put :update, :id => @medium, :medium => @attr
            response.should redirect_to admin_media_path
          end
          
          it "should display a success message" do
            put :update, :id => @medium, :medium => @attr
            flash[:success].should =~ /authorized - there were no changes so no email has been sent/
          end
          
          it "should not send an email notification" do
            pending "how to test?"
          end   
        end
        
        describe "when the entry is authorized with changes" do
        
          before(:each) do
            @original_medium_name = @medium.medium
            @attr = { :medium => "Change", :authorized => true}
          end
          
          it "should change the medium's attributes" do
            put :update, :id => @medium, :medium => @attr
            medium = assigns(:medium)
            @medium.reload
            @medium.medium.should == medium.medium
          end
          
          it "should redirect to the admin_media_path" do
            put :update, :id => @medium, :medium => @attr
            response.should redirect_to admin_media_path
          end
          
          it "should display a success message" do
            put :update, :id => @medium, :medium => @attr
            flash[:success].should =~ /authorized after changes - a notification has been emailed/
          end
          
          describe "send an email notification" do
            
            include EmailSpec::Helpers
            include EmailSpec::Matchers
            
            before(:each) do
              @user = User.find(@medium.user_id)
              @email = UserMailer.medium_accepted_with_changes(@user, @original_medium_name, @medium.medium)
            end
            
            it "should deliver an email to the submitter" do
              put :update, :id => @medium, :medium => @attr
              @email.should deliver_to(@user.email)
            end
          
            it "should show the submitter's name" do
              put :update, :id => @medium, :medium => @attr
              @email.should have_body_text(@user.name)
            end
          
            it "should have a reference to the original submission" do
              put :update, :id => @medium, :medium => @attr
              @email.should have_body_text("You submitted: '#{@original_medium_name}'")
            end
          
            it "should explain the change" do
              put :update, :id => @medium, :medium => @attr
              @email.should have_body_text("We've changed this to: '#{@medium.medium}'")
            end
          
            it "should have the correct subject for the email" do
              put :update, :id => @medium, :medium => @attr
              @email.should have_subject("'Tickets for Training': Training Format accepted - but changed")
            end  
          end  
        end
        
        describe "when the entry is rejected" do
          
          before(:each) do
            @attr = { :authorized => false, :rejection_message => "rejected"}
          end
          
          it "should change the medium's attributes" do
            put :update, :id => @medium, :medium => @attr
            medium = assigns(:medium)
            @medium.reload
            @medium.rejection_message.should == medium.rejection_message
          end
          
          it "should redirect to the admin_media_path" do
            put :update, :id => @medium, :medium => @attr
            response.should redirect_to admin_media_path
          end
          
          it "should display a success message" do
            put :update, :id => @medium, :medium => @attr
            flash[:success].should =~ /rejected and an explanatory email sent/
          end
          
          describe "send an email rejection" do
            
            include EmailSpec::Helpers
            include EmailSpec::Matchers
            
            before(:each) do
              @user = User.find(@medium.user_id)
              @email = UserMailer.medium_rejected(@user, @medium)
            end
            
            it "should deliver an email to the submitter" do
              put :update, :id => @medium, :medium => @attr
              @email.should deliver_to(@user.email)
            end
          
            it "should show the submitter's name" do
              put :update, :id => @medium, :medium => @attr
              @email.should have_body_text(@user.name)
            end
          
            it "should have a reference to the submitted medium" do
              put :update, :id => @medium, :medium => @attr
              @email.should have_body_text("Thank you for submitting '#{@medium.medium}'")
            end
          
            it "should explain the reason for rejection" do
              put :update, :id => @medium, :medium => @attr
              @email.should have_body_text("we can't accept your submission 
                  because #{@medium.rejection_message}")
            end
          
            it "should have the correct subject for the email" do
              put :update, :id => @medium, :medium => @attr
              @email.should have_subject("'Tickets for Training': Training Format not accepted")
            end  
          end
        end
        
        describe "when the entry is modified but left unauthorized" do
          
          before(:each) do
            @attr = { :medium => "Changed", :authorized => false}
          end
          
          it "should change the medium's attributes" do
            put :update, :id => @medium, :medium => @attr
            medium = assigns(:medium)
            @medium.reload
            @medium.rejection_message.should == nil
            @medium.medium.should == medium.medium
            @medium.authorized.should == false
          end
          
          it "should redirect to the admin_media_path" do
            put :update, :id => @medium, :medium => @attr
            response.should redirect_to admin_media_path
          end
          
          it "should display a change notification" do
            put :update, :id => @medium, :medium => @attr
            flash[:notice].should =~ /it remains unauthorized/
          end
        end
      end
      
      describe "failure" do
        
        before(:each) do
          @attr = { :authorized => true, :rejection_message => "rejected"}
        end
        
        it "should not change the medium's attributes" do
          put :update, :id => @medium, :medium => @attr
          medium = assigns(:medium)
          @medium.reload
          @medium.authorized.should_not == medium.authorized
        end
          
        it "should render the edit page" do
          put :update, :id => @medium, :medium => @attr
          response.should render_template("edit")
        end
          
        it "should have the right title" do
          put :update, :id => @medium, :medium => @attr
          response.should have_selector("title", :content => "Authorize training format")
        end
        
        it "should display an error message" do
          put :update, :id => @medium, :medium => @attr
          response.should have_selector("div#error_explanation", :content => "There were problems")
        end
        
      end 
    end
  end
end
