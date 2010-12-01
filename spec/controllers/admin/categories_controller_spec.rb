require 'spec_helper'

describe Admin::CategoriesController do

  render_views
  
  before(:each) do
    @region = Factory(:region)
    @country = Factory(:country, :region_id => @region.id)  
  end
  
  describe "For non-logged-in users" do
  
    before(:each) do
      @user = Factory(:user, :country_id => @country.id) 
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
    
    describe "POST 'create'" do
      
      before(:each) do
        #@user = Factory(:user)
        @attr = { :category => "Abc", :target => "Job", :user_id => @user.id }
      end
      
      it "should not create a new category" do
        lambda do
          post :create, :category => @attr  
        end.should_not change(Category, :count)
      end
      
      it "should give a 'Permission denied' notice" do
        post :create, :category => @attr
        flash[:notice].should =~ /Permission denied/i  
      end
    end
    
    describe "GET 'edit'" do
      
      before(:each) do
        #@user = Factory(:user, :email => "fake@example.com")
        @category = Factory(:category, :authorized => true, :user_id => @user.id)
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
        @category = Factory(:category, :category => "EFG", :target => "Job", 
                            :authorized => true, :user_id => @user.id)
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
    
    describe "DELETE 'destroy'" do
      
      before(:each) do
        #@user = Factory(:user, :email => "anotherfake@example.com")
        @category = Factory(:category, :user_id => @user.id)
      end
      
      it "should be impossible for non-logged-in users" do
        delete :destroy, :id => @category 
        response.should redirect_to(login_path)
      end
      
      it "should not change the total of categories" do
        lambda do
          delete :destroy, :id => @category 
        end.should_not change(Category, :count)
      end
    end 
  end
  
  
  describe "For logged-in non-admins" do
  
    before(:each) do
      @target = 1
      @target_name = "#{Category::TARGET_TYPES[@target]}"
      @user = Factory(:user, :email => "factory@email.com", :country_id => @country.id) 
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
    
    describe "POST 'create'" do
      
      before(:each) do
        @attr = { :category => "Abc", :target => "Job", :user_id => @user.id }
      end
      
      it "should not create a new category" do
        lambda do
          post :create, :category => @attr  
        end.should_not change(Category, :count)
      end
      
      it "should give a 'Permission denied' notice" do
        post :create, :category => @attr
        flash[:notice].should =~ /Permission denied/i  
      end
    end
    
    describe "GET 'edit'" do
      
      before(:each) do
        @category = Factory(:category, :authorized => true, :user_id => @user.id)
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
        @category = Factory(:category, :authorized => true, :user_id => @user.id)
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
    
    describe "DELETE 'destroy'" do
      
      before(:each) do
        
        @category = Factory(:category, :target => @target_name, :user_id => @user.id)
      end
      
      it "should be impossible for non-logged-in users" do
        delete :destroy, :id => @category 
        response.should redirect_to(root_path)
      end
      
      it "should not change the total of categories" do
        lambda do
          delete :destroy, :id => @category 
        end.should_not change(Category, :count)
      end
    end   
  end
  
  describe "For logged-in admins" do
    
    before(:each) do
      @target = 1
      @target_name = "#{Category::TARGET_TYPES[@target]}" 
      @target2 = 2
      @target_name2 = "#{Category::TARGET_TYPES[@target2]}"
      @user = Factory(:user, :email => "admin2@email.com", :admin => true, :country_id => @country.id) 
      test_log_in(@user)
    end
    
    describe "GET 'index'" do
      
      before(:each) do
        @category = Factory(:category,  :authorized => true, :user_id => @user.id, :target => @target_name)
        @category2 = Factory(:category, :category => "Accountancy", 
                                        :target => @target_name,
                                        :authorized => true, 
                                        :user_id => @user.id)
        @category3 = Factory(:category, :category => "Legal", 
                                        :target => @target_name,
                                        :authorized => true, 
                                        :user_id => @user.id)
        @category4 = Factory(:category, :category => "Unauthorized", 
                                        :target => @target_name,
                                        :authorized => false, 
                                        :user_id => @user.id)
                                                                     
        @categories = [@category, @category2, @category3]
        @categories_with_unauthorized = [@category, @category2, @category3, @category4]
        @wrong_target_name = "Fun"
      end
      
      it "should be successful" do
        get :index, :id => @target_name
        response.should be_success
      end
      
      it "should have the right title" do
        get :index, :id => @target_name
        response.should have_selector(:title, 
                    :content => "Training categories => #{@target_name}" )
      end
             
      it "should have an 'Approve Now' link if there are new categories needing authorization" do
        get :index, :id => @target_name
        response.should have_selector("h4", :content => "Also please check")
      end
      
      it "should not have an 'Approve Now' if all categories have been authorized" do
        @category4.update_attribute(:authorized, true)
        get :index, :id => @target_name
        response.should_not have_selector("h4", :content => "Also please check")
      end
      
      it "should include all authorized Categories for the selected group" do
        get :index, :id => @target_name
        @categories.each do |category|
          response.should have_selector("td", :content => category.category)
        end
      end
      
      it "should not include Categories which do not belong to the selected group" do
        get :index, :id => @wrong_target_name
        @categories.each do |category|
          response.should_not have_selector("td", :content => category.category)
        end
      end
      
      it "should not include unauthorized Categories" do
        get :index, :id => @target_name
        @categories_with_unauthorized[3..3].each do |category|
          response.should_not have_selector("td", :content => "Unauthorized")
        end
      end
      
      it "should not have an 'Approval' column" do
        get :index, :id => @target_name
        response.should_not have_selector("th", :content => "Approval")
      end
      
      it "should not include an authorization reminder" do
        get :index, :id => @target_name
        @categories.each do |category|
          response.should_not have_selector("td", :class => "loud", :content => "NEEDED")
        end
      end
      
      it "should include a delete option for all categories that have never been used" do
        get :index, :id => @target_name
        @categories.each do |category|
          response.should have_selector("a",  :href => "/admin/categories/#{category.id}",
                                              :content => "delete")
        end
      end
      
      it "should exclude the delete option for categories that are linked to training" do
        pending "till associations are added"
      end
      
      it "should include a link to the 'edit' form for each category in the list" do
        get :index, :id => @target_name
        @categories.each do |category|
          response.should have_selector("a", :href => "/admin/categories/#{category.id}/edit")
        end
      end
      
      it "should have a 'New category' button including the category type in the label" do
        get :index, :id => @target_name
        response.should have_selector("a",   :href     => "/admin/categories/new?id=#{@target_name}",
                                             :content  => "New category - #{@target_name}")
      end
      
      it "should paginate Categories" do
        30.times do
          @categories << Factory(:category, :category => Factory.next(:category), 
                                :target => @target_name,
                                :authorized => true,
                                :user_id => @user.id)
        end
        get :index, :id => @target_name
        response.should have_selector("div.pagination")
        response.should have_selector("span.disabled", :content => "Previous")
        response.should have_selector("a",  :href => "/admin/categories?id=#{@target_name}&page=2",
                                            :content => "2")
        response.should have_selector("a",  :href => "/admin/categories?id=#{@target_name}&page=2",
                                            :content => "Next")
      end
      
      it "should have a group redirect selector to other category group index pages" do
        get :index, :id => @target_name
        response.should have_selector("a", :href => "/admin/categories?id=#{@target_name2}")
      end
      
      it "should not include its own group in the group redirect selector" do
        get :index, :id => @target_name
        response.should_not have_selector("a", :href => "/admin/categories?id=#{@target_name}")
      end
    end
    
    describe "GET 'new'" do
      
      before(:each) do
        @attr = { :id => @target_name, :user_id => @user.id }
      end
      
      it "should be successful" do
        get :new, @attr
        response.should be_success
      end
      
      it "should have the right title" do
        get :new, @attr
        response.should have_selector(:title, 
                    :content => "New #{@target_name} category" )
      end
      
      it "should have a visible, editable text-box for the new category" do
        get :new, @attr
        response.should have_selector("input",  :name => "category[category]",
                                                :content => "")
      end
      
      it "should have a hidden text-box with the correct grouping pre-set" do
        get :new, @attr
        response.should have_selector("input",  :name => "category[target]",
                                                :type => "hidden",
                                                :value => @target_name)
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
        response.should have_selector("a",      :href => "#{admin_categories_path}?id=#{@target_name}",
                                                :content => "check the current list")
      end
      
      it "should have a submit button" do
        get :new, @attr
        response.should have_selector("input", :value => "Create")
      end  
    end
    
    describe "POST 'create'" do
      
      before(:each) do
        @attr = { :category => "Abc", :target => @target_name, :user_id => @user.id }
        @attr_blank = { :category => "", :target => @target_name, :user_id => @user.id }
      end
        
      describe "failure" do
        
        it "should not create a new Category" do
          lambda do
            post :create, :category => @attr_blank
          end.should_not change(Category, :count)  
        end
        
        it "should render the 'new' page again" do
          post :create, :category => @attr_blank
          response.should render_template("admin/categories/new")
        end
        
        it "should have the right title" do
          post :create, :category => @attr_blank
          response.should have_selector("title", :content => "New #{@target_name} category")
        end
        
        it "should generate an appropriate error message" do
          post :create, :category => @attr_blank
          response.should have_selector("div#error_explanation", :content => "There were problems")
        end
      end
      
      describe "success" do
        
        it "should create a new Category record" do
          lambda do
            post :create, :category => @attr
          end.should change(Category, :count).by(1)  
        end
      
        it "should save the record in the correct Category group" do
          post :create, :category => @attr
          @new_category = Category.find_by_category("Abc")
          @new_category.target.should == @target_name 
        end
        
        it "should include the user_id in the saved record" do
          post :create, :category => @attr
          @new_category_creator = Category.find_by_category("Abc")
          @new_category_creator.user_id.should == @user.id
        end
        
        it "should create a 'Submitted name' attribute, identical to the Category" do
          post :create, :category => @attr
          @new_submission = Category.find_by_category("Abc")
          @new_submission.submitted_name.should == @new_submission.category
        end
        
        it "should create a 'Submitted group' attribute, identical to the Target" do
          post :create, :category => @attr
          @new_entry = Category.find_by_category("Abc")
          @new_entry.submitted_group.should == @new_entry.target
        end
        
        it "should send the creator a thank you message" do
          post :create, :category => @attr
          flash[:success].should =~ /now needs to be authorized/i
        end
        
        it "should return the user to the correct category group listing" do
          post :create, :category => @attr
          response.should redirect_to(admin_categories_path(:id => @target_name))
        end
      end
    end
    
    describe "GET 'edit'" do
      
      before(:each) do
        @category = Factory(:category, :target => @target_name, :authorized => true, :user_id => @user.id)
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
      
      it "should rende@category.user.namer the edit form" do
        get :edit, :id => @category
        response.should be_success
      end
      
      it "should have the right title" do
        get :edit, :id => @category
        response.should have_selector(:title, :content => "Edit category")
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
      
      it "should not have an Authorized check-box if other records are already linked to Category" do
        pending "till associations are added"
      end
      
      it "should show the creator's name" do
        get :edit, :id => @category
        response.should have_selector("p", 
         :content => "#{@category.user.name}")
      end
    
      it "should not show the creator's email address" do
        get :edit, :id => @category
        response.should_not have_selector("p.notes", :content => @category.user.email)
      end
      
      it "should have a 'drop changes' link, redirecting to the correct index list page" do
        get :edit, :id => @category
        response.should have_selector("a",    :href => admin_categories_path(:id => @target_name),
                                              :content => "(drop changes)" )
      end
      
      it "should have a Confirm button" do
        get :edit, :id => @category
        response.should have_selector("input.action_round", :value => "Confirm changes")
      end
     
      it "should not show the correct Target group in a select box" do
          
        #best not to change Categories once users start connecting Training programs to them
          
        get :edit, :id => @authorized_category
        response.should_not have_selector("option", :value => "#{@authorized_category.target}", 
                                                    :selected => "selected",
                                                    :content => @authorized_category.target)
      end
      
      it "should have an uneditable reference to the Target group" do
        get :edit, :id => @authorized_category
        response.should have_selector("p", :content => @authorized_category.target)
      end
      
      it "should not allow an email message to be entered" do
        get :edit, :id => @authorized_category
        response.should_not have_selector("textarea", :content => @authorized_category.message)
      end
      
      it "should not show a change history if the original submission has been unchanged" do
        get :edit, :id => @no_change_cat
        response.should_not have_selector(".mail_quote")
      end
      
      it "should show changes to the Category name originally submitted" do
        get :edit, :id => @change_name
        response.should have_selector(".mail_quote", 
          :content => "from '#{@change_name.submitted_name}' to '#{@change_name.category}'")
      end
        
      it "should show changes to the Group originally submitted" do
        get :edit, :id => @change_group
        response.should have_selector(".mail_quote", 
          :content => "from '#{@change_group.submitted_group}' to '#{@change_group.target}'")
      end      
    end
    
    describe "PUT 'update'" do
      
      describe "failure" do
        
        before(:each) do
          @category = Factory(:category, :authorized => true, :user_id => @user.id)
          @bad_attr = { :category => "", :target => @target_name, :user_id => @user.id }
        end
        
        it "should not update the record" do
          put :update, :id => @category, :category => @bad_attr
          category = assigns(:category)
          @category.reload
          @category.category.should_not == category.category
        end
        
        it "should not send an email message" do
          pending "don't know how to test this"
        end
        
        it "should render the edit page" do
          put :update, :id => @category, :category => @bad_attr
          response.should render_template('edit')
        end
        
        it "should have an error message describing what went wrong" do
          put :update, :id => @category, :category => @bad_attr
          response.should have_selector("div#error_explanation", :content => "There were problems")
        end
        
      end
      
      describe "success" do
        
        before(:each) do
          @category = Factory(:category, :authorized => true, :user_id => @user.id)
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
          response.should redirect_to(admin_categories_path(:id => @target_name))
        end
        
      end  
    end
    
    describe "DELETE 'destroy'" do
      
      before(:each) do
        @category = Factory(:category, :authorized => true, :user_id => @user.id)
      end
      
      describe "success" do
        
        it "should delete the category if it is not associated with any Training Activity" do
          pending "till associations are added"
        end
        
        it "should decrease the number of categories by 1" do
          lambda do
            delete :destroy, :id => @category
          end.should change(Category, :count).by(-1)
        end
        
        it "should redirect to the correct category group index page" do
          delete :destroy, :id => @category
          response.should redirect_to(admin_categories_path(:id => @target_name))
        end
        
        it "should display a message showing what has been deleted" do
          delete :destroy, :id => @category
          flash[:success].should == "#{@category.category} has been deleted."
        end
      end
      
      
      describe "failure" do
      
        it "should not change the number of categories" do
          pending "till associations are added"
        end
        
        it "should redirect to the correct category group index page" do
          pending "till associations are added"
        end
        
        it "should display a failure notice" do
          pending "till associations are added"
        end
          
      end
    end
  end

end
