require 'spec_helper'

describe Admin::CategoryApprovalsController do

  render_views
  
  before(:each) do
    @region = Factory(:region)
    @country = Factory(:country, :region_id => @region.id)
  end
  
  describe "For non-logged-in users" do
  
    before(:each) do
      @user = Factory(:user, :country_id => @country)
    end
    
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
    
    describe "GET 'edit'" do
      
      before(:each) do
        #@user = Factory(:user, :email => "fake@example.com")
        @category = Factory(:category, :user_id => @user.id)
      end
      
      it "should not allow access to the 'edit' form" do
        get :edit, :id => @category
        response.should_not be_success
      end
      
      it "should redirect to the login page" do
        get :edit, :id => @category
        response.should redirect_to(login_path)
      end
    end
    
    describe "PUT 'update'" do
      
      before(:each) do
        #@user = Factory(:user, :email => "fake2@example.com")
        @category = Factory(:category, :category => "EFG", :target => "Job", :user_id => @user.id)
        @attr = { :category => "Abc", :target => "Job", :user_id => @user.id }
      end
      
      it "should not update the Category's attributes" do
        put :update, :id => @category, :category => @attr
        @category.reload
        @category.category.should_not == @attr[:category]
      end
      
      it "should redirect to the root path" do
        put :update, :id => @category, :category => @attr
        response.should redirect_to(root_path)
      end 
    end 
  end
  
  
  describe "For logged-in non-admins" do
  
    before(:each) do
      @target = 1
      @target_name = "#{Category::TARGET_TYPES[@target]}"
      @user = Factory(:user, :country_id => @country.id)
      test_log_in(@user)
    end
    
    describe "GET 'index'" do
      
      it "should not be successful" do
        get :index, :id => @target_name
        response.should_not be_success
      end
      
      it "should redirect to the home page" do
        get :index
        response.should redirect_to(root_path)
      end
    end 
    
    describe "GET 'edit'" do
      
      before(:each) do
        @category = Factory(:category, :user_id => @user.id)
      end
      
      it "should not allow access to the 'edit' form" do
        get :edit, :id => @category
        response.should_not be_success
      end
      
      it "should redirect to the root path" do
        get :edit, :id => @category
        response.should redirect_to(root_path)
      end
    end
    
    describe "PUT 'update'" do
      
      before(:each) do
        @category = Factory(:category, :user_id => @user.id)
        @attr = { :category => "xyz", :user_id => @user.id }
      end
      
      it "should not update the Category" do
        put :update, :id => @category, :category => @attr
        @category.reload
        @category.category.should_not == @attr[:category]
      end
      
      it "should redirect to the root-path" do
        put :update, :id => @category, :category => @attr
        response.should redirect_to(root_path)
      end 
    end  
  end
  
  describe "For logged-in admins" do
    
    before(:each) do
      @target = 1
      @target_name = "#{Category::TARGET_TYPES[@target]}" 
      @user = Factory(:user, :email => "email@example.com", :admin => true, :country_id => @country.id)
      test_log_in(@user)
    end
    
    describe "GET 'index'" do
      
      before(:each) do
        @authorized_cat = "Accountancy"
        @unauthorized_cat = "Basketball"
        @category = Factory(:category, :user_id => @user.id)
        @category2 = Factory(:category, :category => @authorized_cat, 
                                        :target => "Job",
                                        :authorized => true, 
                                        :user_id => @user.id)
        @category3 = Factory(:category, :category => @unauthorized_cat, 
                                        :target => "Fun",
                                        :message => "Blah",
                                        :message_sent => true, 
                                        :user_id => @user.id)                             
        @categories = [@category, @category2, @category3]
       # @wrong_target_name = "Fun"
      end
      
      it "should be successful" do
        get :index
        response.should be_success
      end
      
      it "should have the right title" do
        get :index
        response.should have_selector(:title, 
                    :content => "Unauthorized training categories" )
      end
             
      it "should include all non-authorized Categories, including rejections" do
        correct_response = "rejected" || "new"
        get :index
        @categories.each do |category|
          response.should have_selector("td", :content => correct_response)
        end
      end
      
      it "should not include authorized Categories" do
        get :index
        response.should_not have_selector("td", :content => @authorized_cat )
      end
  
      it "should show which submissions have not been rejected but not yet deleted" do
        get :index
        @categories[2..2].each do |category|
          response.should have_selector("td", :class => "loud", :content => "rejected")
        end
      end
      
      it "should include a delete option for categories which have been rejected" do
        get :index
        @categories[2..2].each do |category|
          response.should have_selector("a",  :href => "/admin/category_approvals/#{category.id}",
                                              :content => "delete")
        end
      end
      
      it "should exclude the delete option for categories which have not been rejected" do
        get :index
        @categories[0..0].each do |category|
          response.should_not have_selector("a",  :href => "/admin/category_approvals/#{category.id}",
                                              :content => "delete")
        end
      end
      
      it "should include a link to the 'edit' form for each category in the list" do
        get :index
        @categories[2..2].each do |category|
          response.should have_selector("a", :href => "/admin/category_approvals/#{category.id}/edit")
        end
      end
    end
    
    describe "GET 'edit'" do
      
      before(:each) do
        @category = Factory(:category, :target => @target_name, :user_id => @user.id)
        @authorized_category = Factory(:category, :category => "Xyz",
                                                  :target => @target_name, 
                                                  :authorized => true,
                                                  :user_id => @user.id)
        @rejected_category = Factory(:category,   :category => "Zyx",
                                                  :target => @target_name, 
                                                  :message_sent => true,
                                                  :user_id => @user.id)
        @change_name = Factory(:category, :category => "Cnc",
                                                  :target => @target_name, 
                                                  :authorized => true,
                                                  :user_id => @user.id,
                                                  :submitted_name => "Cn1")
        @change_group = Factory(:category, :category => "Cgc",
                                                  :target => @target_name, 
                                                  :authorized => true,
                                                  :user_id => @user.id,
                                                  :submitted_group => "Cg1")
        @no_change_cat = Factory(:category, :category => "No change",
                                                  :target => @target_name, 
                                                  :authorized => true,
                                                  :user_id => @user.id,
                                                  :submitted_name => "No change",
                                                  :submitted_group => @target_name)      
      end
      
      it "should render the edit form" do
        get :edit, :id => @category
        response.should be_success
      end
      
      it "should have the right title" do
        get :edit, :id => @category
        response.should have_selector(:title, :content => "Category authorization")
      end
      
      it "should have selected the correct record and have an editable 'Category' field" do
        get :edit, :id => @category
        response.should have_selector("input", :name => "category[category]",
                                               :value => @category.category)
      end
      
      it "should show the correct Authorized value in a check-box" do
        get :edit, :id => @category
        response.should have_selector("input", :name => "category[authorized]",
                                               :type => "checkbox")
      end
      
      it "should show the creator's name" do
        get :edit, :id => @category
        response.should have_selector("p.notes", 
         :content => @category.user.name)
      end
    
      it "should show when the category was submitted" do
        get :edit, :id => @category
        response.should have_selector("p.notes", 
         :content => @category.created_at.strftime('%d-%b-%Y'))
      end
      
      it "should show the creator's email address" do
        get :edit, :id => @category
        response.should have_selector("p.notes", :content => @category.user.email)
      end
      
      it "should have a 'drop changes' link, redirecting to the correct index list page" do
        get :edit, :id => @category
        response.should have_selector("a", :href => admin_category_approvals_path,
                                           :content => "(drop changes)" )
      end
      
      it "should have a Confirm button" do
        get :edit, :id => @category
        response.should have_selector("input.action_round", :value => "Confirm changes")
      end
      
      it "should show the correct Target group in an editable select box" do
        get :edit, :id => @category
        response.should have_selector("option", :value => "#{@category.target}", 
                                                :selected => "selected",
                                                 :content => @category.target)
      end
      
      describe "for unauthorized records" do
      
        it "should have an empty message-box for rejection notes" do
          get :edit, :id => @category
          response.should have_selector("textarea", :content => @category.message)
        end
        
        it "should not show a previous rejection email" do
          get :edit, :id => @category
          response.should_not have_selector(".mail_quote", :content => "Unfortunately, we can't accept")
        end
        
      end
      
      describe "for rejected records" do
        
        it "should not allow a message to be entered" do
          get :edit, :id => @rejected_category
          response.should_not have_selector("textarea", :content => @rejected_category.message)
        end
        
        it "should show the rejection email" do
          get :edit, :id => @rejected_category
          response.should have_selector(".mail_quote", :content => "Unfortunately, we can't accept")
        end
        
      end
    end
    
    describe "PUT 'update'" do
      
      describe "failure" do
        
        before(:each) do
          @category = Factory(:category, :user_id => @user.id)
          @bad_attr = { :category => "", :target => @target_name, :user_id => @user.id }
        end
        
        it "should not update the record" do
          put :update, :id => @category, :category => @bad_attr
          category = assigns(:category)
          @category.reload
          @category.category.should_not == category.category
        end
        
        it "should not send an email message" do
          pending "find out how to test"
        end
        
        it "should render the edit page" do
          put :update, :id => @category, :category => @bad_attr
          response.should render_template("admin/category_approvals/edit")
        end
        
        it "should have an error message describing what went wrong" do
          put :update, :id => @category, :category => @bad_attr
          response.should have_selector("div#error_explanation", :content => "There were problems")
        end
        
      end
      
      describe "success" do
        
        before(:each) do
          @category = Factory(:category, :user_id => @user.id)
          @good_attr = { :category => "Another", :target => @target_name, :user_id => @user.id }
        end
        
        it "should change successfully change the correct record" do
          put :update, :id => @category, :category => @good_attr
          category = assigns(:category)
          @category.reload
          @category.category.should == category.category
        end
        
        it "should redirect to the index list for the Target group" do
          put :update, :id => @category, :category => @good_attr
          response.should redirect_to(admin_category_approvals_path)
        end
        
        describe "email responses" do
        
          include EmailSpec::Helpers
          include EmailSpec::Matchers
          
          describe "if the submission has been newly rejected and an email message composed" do
          
            before(:each) do
              @email_attr = { :category => "Emailable", :target => @target_name, 
                              :authorized => false, :message => "is mis-spelt",
                              :message_sent => false, :user_id => @user.id }
              @email = UserMailer.category_not_authorized(@user, @category)
            end
            
            it "should deliver an email to the submitter" do
              put :update, :id => @category, :category => @email_attr
              @email.should deliver_to(@user.email)
            end
          
            it "should show the submitter's name in the email" do
              put :update, :id => @category, :category => @email_attr
              @email.should have_body_text(@user.name)
            end
          
            it "should have a reference to the original submission in the email" do
              put :update, :id => @category, :category => @email_attr
              @email.should have_body_text("Thank you for submitting #{@category.category} as a 
                  new Category in the #{@category.target} group.")
            end
          
            it "should include the correct content in the email" do
              put :update, :id => @category, :category => @email_attr
              @email.should have_body_text("we can't accept your submission 
                because #{@category.message}")
            end
          
            it "should have the correct subject for the email" do
              put :update, :id => @category, :category => @email_attr
              @email.should have_subject("'Tickets for Training': your Category submission")
            end
          
            it "should update 'Message sent' to true after sending the email" do
              put :update, :id => @category, :category => @email_attr
              @category.reload
              @category.message_sent.should == true
            end
          
            it "should post a flash message confirming that the email has been sent" do
              put :update, :id => @category, :category => @email_attr
              flash[:success].should =~ /rejected/i
            end
          end
        
          describe "if the Category has been authorized" do
          
            before(:each) do
              @no_email_attr = {  :category => "Not emailable", :target => @target_name, 
                                  :authorized => true,
                                  :message_sent => false, :user_id => @user.id,
                                  :submitted_name => "Not emailable", :submitted_group => @target_name }
              @email = UserMailer.category_not_authorized(@user, @category)
            end

          
            it "should post a flash message showing that the Category has been authorized" do
              pending
            end
          
          end
        
          describe "if the Category has been previously rejected" do
          
            it "should not send an email message" do
              pending
            end
          
            it "should post a flash warning showing that approval has still not been given" do
              pending
            end
          
          end
        end
      end  
    end
  end
end
