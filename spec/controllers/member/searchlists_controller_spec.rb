require 'spec_helper'

describe Member::SearchlistsController do

  render_views
  
  before(:each) do
    @region = Factory(:region)
    @country = Factory(:country, :region_id => @region.id)
    @user = Factory(:user, :country_id => @country.id)
    @category = Factory(:category, :user_id => @user.id, :authorized => true)
    @searchlist = Factory(:searchlist, :user_id => @user.id, :category_id => @category.id) 
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
        get :new, :group => "Job"
        response.should_not be_success
      end
      
      it "should redirect to the login page" do
        get :new, :group => "Job"
        response.should redirect_to(login_path)
      end
    end

    describe "POST 'create'" do
      
      before(:each) do
        @good_attr = { :user_id => @user.id, :category_id => @category.id,
                       :focus => "Job", :topics => "Appraisal", :country_id => @country.id }
      end
      
      it "should not add a new search-list" do
        lambda do
          post :create, :searchlist => @good_attr 
        end.should_not change(Searchlist, :count)
      end
      
      it "should redirect to the root path" do
        post :create, :searchlist => @good_attr 
        response.should redirect_to root_path 
      end
    end
    
    describe "GET 'edit'" do
      
      it "should not be successful" do
        get :edit, :id => @searchlist
        response.should_not be_success
      end
      
      it "should redirect to the login page" do
        get :edit, :id => @searchlist
        response.should redirect_to login_path
      end
      
    end
    
    describe "PUT 'update'" do
      
      before(:each) do
        @good_attr = { :user_id => @user.id, :category_id => @category.id,
                       :focus => "Job", :topics => "Pay", :country_id => @country.id }
      end
      
      it "should not change the searchlist attributes" do
        put :update, :id => @searchlist, :resource => @good_attr
        @searchlist.reload
        @searchlist.topics.should_not == "Appraisal"
      end
      
      it "should redirect to the root path" do
        put :update, :id => @searchlist, :resource => @good_attr
        response.should redirect_to root_path
      end
    end
    
    describe "DELETE 'destroy'" do
      
      it "should not delete the searchlist" do
        original_count = Searchlist.count(:all)
        delete :destroy, :id => @searchlist
        new_count = Searchlist.count(:all)
        new_count.should == original_count
      end
    
      it "should redirect to the login path" do
        delete :destroy, :id => @searchlist
        response.should redirect_to login_path
      end
    end
    
  end
  
  describe "for logged-in users" do
    
    before(:each) do
      test_log_in(@user)
    end
    
    describe "GET 'index'" do
      it "should be successful" do
        get :index
        response.should be_success
      end
      
      it "should have the right title" do
        get :index
        response.should have_selector("title", :content => "Your search preferences")  
      end
      
      it "should enumerate the number of search-lists already created" do
        get :index
        response.should have_selector("h5", :content => "1 search-list defined out of possible 10")
      end
      
      it "should have a 'new searchlist' link" do
        get :index
        response.should have_selector("a", :href => member_focus_path)
      end
      
      it "should list all search-lists created by the current user" do
        @searchlist2 = Factory(:searchlist, :user_id => @user.id, :category_id => @category.id,
                               :topics => "Achievement")
        @searchlists = [@searchlist, @searchlist2]                       
        get :index
        @searchlists.each do |s|
          response.should have_selector(".notes", :content => s.topics)
        end
      end
      
      it "should not include search-lists created by other users" do
        @other_user = Factory(:user, :email => "other@example.com", :country_id => @country.id)
        @other_user_searchlist = Factory(:searchlist, :user_id => @other_user.id, 
                                                      :category_id => @category.id,
                                                      :topics => "Attendance")
        get :index
        response.should_not have_selector(".notes", :content => "Attendance")
      end
      
      it "should include the 'focus' group" do
        get :index
        response.should have_selector(".notes", :content => @searchlist.focus)
      end
      
      it "should include the category" do
        get :index
        response.should have_selector(".notes", :content => @searchlist.category.category)
      end
      
      it "should include the format selected, if any" do
        @medium = Factory(:medium, :user_id => @user.id, :authorized => true)
        @searchlist2 = Factory(:searchlist, :user_id => @user.id, :category_id => @category.id,
                               :topics => "Achievement", :medium_id => @medium.id)
        get :index
        response.should have_selector(".notes", :content => @searchlist2.medium.medium)
      end
      
      it "should state that 'Any' format is acceptable if none has been specified" do
        get :index
        response.should have_selector(".notes", :content => "Any")
      end
      
      it "should include the submitted keywords" do
        get :index
        response.should have_selector(".notes", :content => @searchlist.topics)
      end
      
      it "should have a link to the 'edit' form" do
        get :index
        response.should have_selector("a", :href => edit_member_searchlist_path(@searchlist))
      end
      
      it "should have a link to 'delete'" do
        get :index
        response.should have_selector("a",  :href => member_searchlist_path(@searchlist),
                                                  :content => "delete")
      end
      
      describe "location settings when the format has not been specified or requires attendance" do
        
        before(:each) do
          @medium_attendreq = Factory(:medium, :user_id => @user.id, :attendance => true, 
                                                 :medium => "Classroom", :authorized => true)
          @attendreq_searchlist = Factory(:searchlist, :user_id => @user.id, :category_id => @category.id,
                                          :medium_id => @medium_attendreq.id)
        end
        
        describe "and a region has been entered" do
          
          before(:each) do
            @region2 = Factory(:region, :region => "Africa")
            @search_nomedium_region = Factory(:searchlist, :user_id => @user.id, 
                                              :category_id => @category.id, :region_id => @region.id,
                                              :country_id => @country.id, :proximity => 4)
            @search_attendmedium_region = Factory(:searchlist, :user_id => @user.id, 
                                              :category_id => @category.id, :region_id => @region2.id,
                                              :country_id => @country.id, :proximity => 4,
                                              :medium_id => @medium_attendreq.id)
            @new_searchlists = [@search_nomedium_region, @search_attendmedium_region]
                                              
          end
          
          it "should mention the region in 'location'" do
            get :index
            @new_searchlists.each do |ns|
              response.should have_selector(".notes", :content => ns.region.region)
            end
          end
          
          it "should ignore any country setting" do
            get :index
            @new_searchlists.each do |ns|
              response.should_not have_selector(".notes", :content => ns.country.name)
            end
          end
          
          it "should ignore any proximity setting" do
            get :index
            @new_searchlists.each do |ns|
              response.should_not have_selector(".notes", :content => "km")
            end
          end
        end
        
        describe "and a country other than the users country has been entered, but not the region" do
          
          before(:each) do
            
            @country2 = Factory(:country, :region_id => @region.id, :name => "Wonga",
                                          :country_code => "WNG" ) 
            @search_nomedium_country = Factory(:searchlist, :user_id => @user.id, 
                                              :category_id => @category.id,
                                              :country_id => @country2.id, :proximity => 4)
            @search_attendmedium_country = Factory(:searchlist, :user_id => @user.id, 
                                              :category_id => @category.id,
                                              :country_id => @country2.id, :proximity => 4,
                                              :medium_id => @medium_attendreq.id)
            @new_searchlists = [@search_nomedium_country, @search_attendmedium_country]
          end
          
          it "should not include a region setting" do
            get :index
            @new_searchlists.each do |ns|
              response.should_not have_selector(".notes", :content => @region.region)
            end
          end
          
          it "should correctly mention the country" do
            get :index
            @new_searchlists.each do |ns|
              response.should have_selector(".notes", :content => ns.country.name)
            end
          end
          
          it "should ignore any proximity options" do
            get :index
            @new_searchlists.each do |ns|
              response.should_not have_selector(".notes", :content => "km")
            end
          end
          
        end
        
        describe "when proximity settings have been entered, but not region or another country" do
          
          before(:each) do
        
            @search_nomedium_proximity = Factory(:searchlist, :user_id => @user.id, 
                                              :category_id => @category.id,
                                              :proximity => 4)
            @search_attendmedium_proximity = Factory(:searchlist, :user_id => @user.id, 
                                              :category_id => @category.id,
                                              :proximity => 4,
                                              :medium_id => @medium_attendreq.id)
            @now_searchlists = [@search_nomedium_proximity, @search_attendmedium_proximity]
          end
          
          it "should not include a region setting" do
            get :index
            @now_searchlists.each do |ns|
              response.should_not have_selector(".notes", :content => @region.region)
            end
          end
          
          it "should include a reference to the user's country" do
            get :index
            @now_searchlists.each do |ns|
              response.should have_selector(".notes", :content => @user.country.name)
            end
          end
          
          it "should include the correct distance" do
            get :index
            @now_searchlists.each do |ns|
              response.should have_selector(".notes", :content => "km")
            end
          end
          
        end
        
        describe "when no proximity, region or other country settings have been selected" do
          
          it "should show an error in Location set-up" do
            get :index
            response.should have_selector(".notes", :content => "Set-up error for location")
          end
          
          it "should not include a region setting" do
            get :index
            response.should_not have_selector(".notes", :content => @region.region)
          end
          
          it "should not include a proximity setting" do
            get :index
            response.should_not have_selector(".notes", :content => "km")
          end
        end
        
        
      end
      
      describe "location settings when the format does not require physical attendance" do
        
        before(:each) do
          @medium_unscheduled = Factory(:medium, :user_id => @user.id, :user_id => @user.id,
                                                 :medium => "Classroom", :authorized => true)
          @unscheduled_searchlist1 = Factory(:searchlist, :user_id => @user.id, :category_id => @category.id,
                                          :region_id => @region.id, :medium_id => @medium_unscheduled.id)
          @unscheduled_searchlist2 = Factory(:searchlist, :user_id => @user.id, :category_id => @category.id,
                                          :country_id => @country.id, :medium_id => @medium_unscheduled.id)
          @us_searchlists = [@unscheduled_searchlist1, @unscheduled_searchlist2]
        end
        
        it "should declare that Location is not applicable" do
          get :index
          @us_searchlists.each do |us|
            response.should have_selector(".notes", :content => "Not applicable")
          end
        end
        
        it "should not include a region in 'location' if a region has been set" do
          get :index
          @us_searchlists.each do |us|
            response.should_not have_selector(".notes", :content => @region.region)
          end
        end
      end
      
      describe "when 10 search-lists have already been created" do
        
        before(:each) do     
          @slists = [@searchlist]
          9.times do
            @slists << Factory(:searchlist, :user_id => @user.id, :category_id => @category.id)
          end
        end
        
        it "should warn that no more search-lists can be created" do
          get :index
          response.should have_selector(".loud", 
                :content => "You'll need to delete a search before you can add another")
        end
        
        it "should not have a 'new searchlist' link" do
          get :index
          response.should_not have_selector("a", :href => member_focus_path)
        end
      end
    end

    describe "GET 'new'" do
     
      it "should be successful" do
        get :new, :group => "Job"
        response.should be_success
      end
      
      it "should have the right title" do
        get :new, :group => "Job"
        response.should have_selector("title", :content => "Preferences: build a search-list")
      end
      
      it "should have a hidden 'user_id' field, defaulting to the current user" do
        get :new, :group => "Job"
        response.should have_selector("input", :name => "searchlist[user_id]",
                                               :type => "hidden",
                                               :value => @user.id.to_s)
      end
      
      it "should have a hidden 'focus' field" do
        get :new, :group => "Job"
        response.should have_selector("input", :name => "searchlist[focus]",
                                               :type => "hidden",
                                               :value => "Job")
      end
      
      it "should have a blank 'category' select field" do
        get :new, :group => "Job"
        response.should have_selector("select", :name => "searchlist[category_id]",
                                                :content => "Must be selected")
      end
      
      it "should have a blank 'topics' text-field" do
        get :new, :group => "Job"
        response.should have_selector("input", :name => "searchlist[topics]",
                                               :type => "text")
      end
      
      it "should have a blank 'preferred format' select field" do
        get :new, :group => "Job"
        response.should have_selector("select", :name => "searchlist[medium_id]",
                                                :content => "Any format")
      end
      
      it "should have a blank 'region' select field" do
        get :new, :group => "Job"
        response.should have_selector("select", :name => "searchlist[region_id]",
                                                :content => "Not selected")
      end
      
      it "should have a blank 'country' select field" do
        get :new, :group => "Job"
        response.should have_selector("select", :name => "searchlist[country_id]",
                                                :content => "Not selected")
      end
      
      it "should have a blank 'proximity' select field" do
        get :new, :group => "Job"
        response.should have_selector("select", :name => "searchlist[proximity]",
                                                :content => "Not selected")
      end
      
      it "should have the correct options for 'proximity'" do
        get :new, :group => "Job"
        response.should have_selector("option", :value => "3",
                                                :content => "within around 500 km")
        response.should have_selector("option", :value => "4",
                                                :content => "within around 150 km")
        response.should have_selector("option", :value => "5",
                                                :content => "within around 50 km")
      end
      
      it "should have a submission button" do
        get :new, :group => "Job"
        response.should have_selector("input", :value => "Create the search-list")
      end
      
      it "should have a 'cancellation' link" do
        get :new, :group => "Job"
        response.should have_selector("a", :href => member_searchlists_path,
                                           :content => "(cancel the entry)")
      end
    end

    describe "POST 'create'" do
      
      describe "success" do
        
        describe "when an 'attendance required' format or no format is assigned" do
          
          before(:each) do
            @country2 = Factory(:country, :region_id => @region.id, :name => "Wonga",
                                          :country_code => "WNG" ) 
            @medium_attendreq = Factory(:medium, :user_id => @user.id, :attendance => true, 
                                                 :medium => "Seminar", :authorized => true)
          end
          
          describe "and when a region is selected" do
            before(:each) do
              @attributes = { :focus => "Job", :user_id => @user.id.to_s, 
                                     :category_id => @category.id.to_s,
                                     :topics => "This", :region_id => @region.id }                            
            end
            
            it "should add a new searchlist" do
              lambda do
                post :create, :searchlist => @attributes
              end.should change(Searchlist, :count).by(1) 
            end
            
            it "should retain the region location, but discard country and proximity" do
              post :create, :searchlist => @attributes
              @new_searchlist = Searchlist.find(:last)
              @new_searchlist.region_id.should == @region.id
              @new_searchlist.country_id.should == nil
              @new_searchlist.proximity.should == nil
            end
              
            it "should redirect to the 'index' page" do
              post :create, :searchlist => @attributes
              response.should redirect_to member_searchlists_path
            end
            
            it "should display a success message" do
              post :create, :searchlist => @attributes
              flash[:success].should =~ /Your search-list has been successfully created/
            end
            
          end
        
          describe "and when another country is selected" do
            before(:each) do
              @attributes = { :focus => "Job", :user_id => @user.id.to_s, 
                                     :category_id => @category.id.to_s, :medium_id => @medium_attendreq.id,
                                     :topics => "This", :country_id => @country2.id,
                                     :proximity => 3 }
            end
            
            it "should add a new searchlist" do
              lambda do
                post :create, :searchlist => @attributes
              end.should change(Searchlist, :count).by(1) 
            end
            
            it "should retain the country location but discard any proximity attribute" do
              post :create, :searchlist => @attributes
              @new_searchlist = Searchlist.find(:last)
              @new_searchlist.country_id.should == @country2.id
              @new_searchlist.proximity.should == nil
            end
            
            it "should redirect to the 'index' page" do
              post :create, :searchlist => @attributes
              response.should redirect_to member_searchlists_path
            end
            
            it "should display a success message" do
              post :create, :searchlist => @attributes
              flash[:success].should =~ /Your search-list has been successfully created/
            end
            
          end
        
          describe "and when a 'proximity' is selected" do
            before(:each) do
              @attributes = { :focus => "Job", :user_id => @user.id.to_s, 
                                     :category_id => @category.id.to_s, :medium_id => @medium_attendreq.id,
                                     :topics => "This", :proximity => 3 }
            end
            
            it "should add a new searchlist" do
              lambda do
                post :create, :searchlist => @attributes
              end.should change(Searchlist, :count).by(1) 
            end
            
            it "should retain the proximity attribute and the user's country_id" do
              post :create, :searchlist => @attributes
              @new_searchlist = Searchlist.find(:last)
              @new_searchlist.country_id.should == @user.country_id
              @new_searchlist.proximity.should == 3
            end
            
            it "should redirect to the 'index' page" do
              post :create, :searchlist => @attributes
              response.should redirect_to member_searchlists_path
            end
            
            it "should display a success message" do
              post :create, :searchlist => @attributes
              flash[:success].should =~ /Your search-list has been successfully created/
            end
          end
        
          describe "and when no location selections are made" do
            before(:each) do
              @attributes = { :focus => "Job", :user_id => @user.id.to_s, 
                                     :category_id => @category.id.to_s, :medium_id => @medium_attendreq.id,
                                     :topics => "This" }
            end
            
            it "should add a new searchlist" do
              lambda do
                post :create, :searchlist => @attributes
              end.should change(Searchlist, :count).by(1) 
            end
            
            it "should add back the user's country_id" do
              post :create, :searchlist => @attributes
              @new_searchlist = Searchlist.find(:last)
              @new_searchlist.country_id.should == @user.country_id
            end
            
            it "should redirect to the 'index' page" do
              post :create, :searchlist => @attributes
              response.should redirect_to member_searchlists_path
            end
            
            it "should display a success message" do
              post :create, :searchlist => @attributes
              flash[:success].should =~ /Your search-list has been successfully created/
            end
          end
        end
        
        describe "when attendance is not required" do
          
          before(:each) do
            @medium_no_attendreq = Factory(:medium, :user_id => @user.id, :attendance => false, 
                                                 :medium => "DVD", :authorized => true)
            @attributes = { :focus => "Job", :user_id => @user.id.to_s, 
                                     :category_id => @category.id.to_s, :medium_id => @medium_no_attendreq.id,
                                     :topics => "This", :region_id => @region.id }     
          end
          
          it "should add a new searchlist" do
            lambda do
              post :create, :searchlist => @attributes
            end.should change(Searchlist, :count).by(1) 
          end
            
          it "should not include the country_id (or the region_id)" do
            post :create, :searchlist => @attributes
            @new_searchlist = Searchlist.find(:last)
            @new_searchlist.country_id.should == nil
            @new_searchlist.region_id.should == nil
          end
          
          it "should redirect to the 'index' page" do
            post :create, :searchlist => @attributes
            response.should redirect_to member_searchlists_path
          end
            
          it "should display a success message" do
            post :create, :searchlist => @attributes
            flash[:success].should =~ /Your search-list has been successfully created/
          end
        end
      end
      
      describe "failure" do
        before(:each) do
          @attributes = { :focus => "Job", :user_id => @user.id.to_s, 
                                     :category_id => nil,
                                     :topics => nil }          
        end
        
        it "should not add a new searchlist" do
          lambda do
            post :create, :searchlist => @attributes
          end.should_not change(Searchlist, :count) 
        end
        
        it "should redisplay the 'new' page" do
          post :create, :searchlist => @attributes
          response.should render_template("new")
        end
        
        it "should have the right title" do
          post :create, :searchlist => @attributes
          response.should have_selector("title", :content => "Preferences: build a search-list")
        end
        
        it "should have a failure message explaining the errors" do
          post :create, :searchlist => @attributes
          response.should have_selector("div#error_explanation", :content => "There were problems")     
        end
      end
    end
    
    describe "GET 'edit'" do
      
      it "should be successful" do
        get :edit, :id => @searchlist
        response.should be_success
      end
      
      it "should have the right title" do
        get :edit, :id => @searchlist
        response.should have_selector("title", :content => "Edit search-list")
      end
      
      it "should have a hidden 'user_id' field, defaulting to the current user" do
        get :edit, :id => @searchlist
        response.should have_selector("input", :name => "searchlist[user_id]",
                                               :type => "hidden",
                                               :value => @user.id.to_s)
      end
      
      it "should have a hidden 'focus' field" do
        get :edit, :id => @searchlist
        response.should have_selector("input", :name => "searchlist[focus]",
                                               :type => "hidden",
                                               :value => "Job")
      end
      
      it "should have a 'category' select field" do
        get :edit, :id => @searchlist.id
        response.should have_selector("select", :name => "searchlist[category_id]",
                                                :content => @searchlist.category.category)
      end
      
      it "should have a 'topics' text-field" do
        get :edit, :id => @searchlist
        response.should have_selector("input", :name => "searchlist[topics]",
                                               :type => "text",
                                               :value => @searchlist.topics)
      end
      
      it "should have a blank 'preferred format' select field" do
        get :edit, :id => @searchlist
        response.should have_selector("select", :name => "searchlist[medium_id]",
                                                :content => "Any format")
      end
      
      it "should have a 'region' select field" do
        get :edit, :id => @searchlist
        response.should have_selector("select", :name => "searchlist[region_id]",
                                                :content => "Not selected")
      end
      
      it "should have a 'country' select field" do
        get :edit, :id => @searchlist
        response.should have_selector("select", :name => "searchlist[country_id]",
                                                :content => "Not selected")
      end
      
      it "should have a 'proximity' select field" do
        get :edit, :id => @searchlist
        response.should have_selector("select", :name => "searchlist[proximity]",
                                                :content => "Not selected")
      end
      
      it "should have the correct options for 'proximity'" do
        get :edit, :id => @searchlist
        response.should have_selector("option", :value => "3",
                                                :content => "within around 500 km")
        response.should have_selector("option", :value => "4",
                                                :content => "within around 150 km")
        response.should have_selector("option", :value => "5",
                                                :content => "within around 50 km")
      end
      
      it "should have a submission button" do
        get :edit, :id => @searchlist
        response.should have_selector("input", :value => "Confirm changes")
      end
      
      it "should have a 'cancellation' link" do
        get :edit, :id => @searchlist
        response.should have_selector("a", :href => member_searchlists_path,
                                           :content => "(drop changes)")
      end
    end
    
    describe "PUT 'update'" do
      
      describe "success" do
          
        describe "when attendance is required or not specified" do
        
          before(:each) do
            @country2 = Factory(:country, :region_id => @region.id, :name => "Wonga",
                                          :country_code => "WNG" ) 
            @medium_attendreq = Factory(:medium, :user_id => @user.id, :attendance => true, 
                                                 :medium => "Seminar", :authorized => true)
          end
        
          describe "and when region is entered" do
            
            before(:each) do
              @attributes = { :topics => "These those", :region_id => @region.id,
                              :medium_id => @medium_attendreq.id }
            end
            
            it "should update the searchlist attributes and remove the country_id attribute" do
              put :update, :id => @searchlist, :searchlist => @attributes
              searchlist = assigns(:searchlist)
              @searchlist.reload
              @searchlist.topics.should == searchlist.topics
              @searchlist.region_id.should == searchlist.region_id
              @searchlist.medium_id.should == searchlist.medium_id
              @searchlist.country_id.should == searchlist.country_id
            end
            
            it "should redirect to the index page" do
              put :update, :id => @searchlist, :searchlist => @attributes
              response.should redirect_to member_searchlists_path
            end
            
            it "should display a success message" do
              put :update, :id => @searchlist, :searchlist => @attributes
              flash[:success].should =~ /Your search-list has been successfully updated/
            end
          end
          
          describe "and when another country is entered (but not region)" do
            
            before(:each) do
              @attributes = { :topics => "These those", :country_id => @country2.id,
                              :medium_id => @medium_attendreq.id, :proximity => 4 }
            end
            
            it "should update the searchlist attributes and remove the proximity attribute" do
              put :update, :id => @searchlist, :searchlist => @attributes
              searchlist = assigns(:searchlist)
              @searchlist.reload
              @searchlist.topics.should == searchlist.topics
              @searchlist.country_id.should == searchlist.country_id
              @searchlist.medium_id.should == searchlist.medium_id
              @searchlist.proximity.should == searchlist.proximity
            end
            
            it "should redirect to the index page" do
              put :update, :id => @searchlist, :searchlist => @attributes
              response.should redirect_to member_searchlists_path
            end
            
            it "should display a success message" do
              put :update, :id => @searchlist, :searchlist => @attributes
              flash[:success].should =~ /Your search-list has been successfully updated/
            end
          end
          
          describe "and when proximity is defined (but not region and the country is not the user's)" do
            
            before(:each) do
              @attributes = { :topics => "These those",
                              :medium_id => @medium_attendreq.id, :proximity => 4 }
            end
            
            it "should update the searchlist attributes and include the user's country" do
              put :update, :id => @searchlist, :searchlist => @attributes
              searchlist = assigns(:searchlist)
              @searchlist.reload
              @searchlist.topics.should == searchlist.topics
              @searchlist.country_id.should == @user.country_id
              @searchlist.medium_id.should == searchlist.medium_id
              @searchlist.proximity.should == searchlist.proximity
            end
            
            it "should redirect to the index page" do
              put :update, :id => @searchlist, :searchlist => @attributes
              response.should redirect_to member_searchlists_path
            end
            
            it "should display a success message" do
              put :update, :id => @searchlist, :searchlist => @attributes
              flash[:success].should =~ /Your search-list has been successfully updated/
            end
          end
          
          describe "when region and proximity are not defined and a foreign country has not been entered" do
            
            before(:each) do
              @attributes = { :topics => "These those",
                              :medium_id => @medium_attendreq.id }
            end
            
            it "should update the searchlist attributes and include the user's country" do
              put :update, :id => @searchlist, :searchlist => @attributes
              searchlist = assigns(:searchlist)
              @searchlist.reload
              @searchlist.topics.should == searchlist.topics
              @searchlist.country_id.should == @user.country_id
              @searchlist.medium_id.should == searchlist.medium_id
            end
            
            it "should redirect to the index page" do
              put :update, :id => @searchlist, :searchlist => @attributes
              response.should redirect_to member_searchlists_path
            end
            
            it "should display a success message" do
              put :update, :id => @searchlist, :searchlist => @attributes
              flash[:success].should =~ /Your search-list has been successfully updated/
            end
          end
        
        end
      
        describe "when attendance is not required" do
        
          before(:each) do
            @medium_no_attendreq = Factory(:medium, :user_id => @user.id, :attendance => false, 
                                                 :medium => "DVD", :authorized => true)
            @attributes = { :topics => "One two three", :medium_id => @medium_no_attendreq.id,
                            :region_id => @region.id }     
          end
          
          it "should update the searchlist attributes but exclude location details" do
            put :update, :id => @searchlist, :searchlist => @attributes
            searchlist = assigns(:searchlist)
            @searchlist.reload
            @searchlist.topics.should == searchlist.topics
            @searchlist.country_id.should == nil
            @searchlist.medium_id.should == searchlist.medium_id
          end
            
          it "should redirect to the index page" do
            put :update, :id => @searchlist, :searchlist => @attributes
            response.should redirect_to member_searchlists_path
          end
            
          it "should display a success message" do
            put :update, :id => @searchlist, :searchlist => @attributes
            flash[:success].should =~ /Your search-list has been successfully updated/
          end        
        end
        
      end
      
      describe "failure" do
        
        before(:each) do
          @attributes = { :category_id => nil, :topics => nil }          
        end
        
        it "should not update the searchlist attributes" do
          put :update, :id => @searchlist, :searchlist => @attributes
          searchlist = assigns(:searchlist)
          @searchlist.reload
          @searchlist.topics.should_not == searchlist.topics
          @searchlist.category_id.should_not == searchlist.category_id
        end
        
        it "should render the 'Edit' page" do
          put :update, :id => @searchlist, :searchlist => @attributes
          response.should render_template("edit")
        end
          
        it "should display an appropriate error message" do
          put :update, :id => @searchlist, :searchlist => @attributes
          response.should have_selector("div#error_explanation", :content => "There were problems")
        end
        
        it "should have the right title" do
          put :update, :id => @searchlist, :searchlist => @attributes
          response.should have_selector("title", :content => "Edit search-list") 
        end
      end
      
    end
    
    describe "DELETE 'destroy'" do
      
      before(:each) do
        @deletable_searchlist = Factory(:searchlist, :user_id => @user.id, :category_id => @category.id)
      end
      
      it "should delete the searchlist" do
        original_count = Searchlist.count(:all)
        delete :destroy, :id => @deletable_searchlist
        new_count = Searchlist.count(:all)
        new_count.should == original_count - 1
      end
      
      it "should redirect to the searchlist index" do
        delete :destroy, :id => @deletable_searchlist
        response.should redirect_to member_searchlists_path
      end
      
      it "should confirm the deletion with a success message" do
        delete :destroy, :id => @deletable_searchlist
        flash[:success].should =~ /Search-list successfully deleted/
      end
    end
  end
  
end
