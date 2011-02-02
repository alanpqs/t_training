require 'spec_helper'

describe Business::PagesController do

  render_views
  
  before(:each) do
    @region = Factory(:region)
    @country = Factory(:country, :region_id => @region.id)
    @user = Factory(:user, :country_id => @country.id)
    @provider = Factory(:user,  :name => "Provider", :email => "provider@email.com", 
                                :vendor => true, :country_id => @country.id)  
  end
  
  describe "for non-logged-in users" do
    
    describe "GET 'home'" do
      
      it "should not be successful" do
        get :home
        response.should_not be_success
      end
      
      it "should redirect to the login page" do
        get :home
        response.should redirect_to login_path
      end
    end
    
    describe "GET 'resource_group'" do
      
      it "should not be successful" do
        get :resource_group
        response.should_not be_success
      end
      
      it "should redirect to the login page" do
        get :resource_group
        response.should redirect_to login_path
      end
    end
    
    describe "GET 'duplicate resource to vendor'" do
      
      it "should not be successful" do
        get :duplicate_resource_to_vendor
        response.should_not be_success
      end
      
      it "should redirect to the login page" do
        get :duplicate_resource_to_vendor
        response.should redirect_to login_path
      end
      
    end
    
    describe "GET 'tickets_menu'" do
      
      it "should not be successful" do  
        get :tickets_menu
        response.should_not be_success
      end
      
      it "should redirect to the login page" do
        get :tickets_menu
        response.should redirect_to login_path
      end
    end
    
    describe "GET 'program_selection'" do
      
      it "should not be successful" do  
        get :program_selection
        response.should_not be_success
      end
      
      it "should redirect to the login page" do
        get :program_selection
        response.should redirect_to login_path
      end
    end
    
    describe "GET 'resource_selection'" do
      
      it "should not be successful" do  
        get :resource_selection
        response.should_not be_success
      end
      
      it "should redirect to the login page" do
        get :resource_selection
        response.should redirect_to login_path
      end
    end
  end
  
  describe "for logged-in users without a vendor attribute" do
    
    before(:each) do
      test_log_in(@user)
    end
    
    describe "GET 'home'" do
      
      it "should not be successful" do
        get :home
        response.should_not be_success
      end
      
      it "should redirect to the user home page" do
        get :home
        response.should redirect_to user_path(@user)
      end
      
      it "should have a message explaining how to sign up as a vendor" do
        get :home
        flash[:notice].should =~ /If you want to sell training/
      end
    end
    
    describe "GET 'resource_group'" do
      
      it "should not be successful" do
        get :resource_group
        response.should_not be_success
      end
      
      it "should redirect to the user home page" do
        get :resource_group
        response.should redirect_to user_path(@user)
      end
      
      it "should have a message explaining how to sign up as a vendor" do
        get :resource_group
        flash[:notice].should =~ /If you want to sell training/
      end
    end
    
    describe "GET 'duplicate resource to vendor'" do
      
      it "should not be successful" do
        get :duplicate_resource_to_vendor
        response.should_not be_success
      end
      
      it "should redirect to the user home page" do
        get :duplicate_resource_to_vendor
        response.should redirect_to user_path(@user)
      end
      
      it "should have a message explaining how to sign up as a vendor" do
        get :duplicate_resource_to_vendor
        flash[:notice].should =~ /If you want to sell training/
      end
    end
    
    describe "GET 'tickets_menu'" do
      
      it "should not be successful" do  
        get :tickets_menu
        response.should_not be_success
      end
      
      it "should redirect to the user home page" do
        get :tickets_menu
        response.should redirect_to user_path(@user)
      end
      
      it "should have a message explaining how to sign up as a vendor" do
        get :tickets_menu
        flash[:notice].should =~ /If you want to sell training/
      end
    end
    
    describe "GET 'program_selection'" do
      
      it "should not be successful" do  
        get :program_selection
        response.should_not be_success
      end
      
      it "should redirect to the user home page" do
        get :program_selection
        response.should redirect_to user_path(@user)
      end
      
      it "should have a message explaining how to sign up as a vendor" do
        get :program_selection
        flash[:notice].should =~ /If you want to sell training/
      end
    end
    
    describe "GET 'resource_selection'" do
      
      it "should not be successful" do  
        get :resource_selection
        response.should_not be_success
      end
      
      it "should redirect to the user home page" do
        get :resource_selection
        response.should redirect_to user_path(@user)
      end
      
      it "should have a message explaining how to sign up as a vendor" do
        get :resource_selection
        flash[:notice].should =~ /If you want to sell training/
      end
    end
  end
  
  describe "for logged-in users with the vendor attribute set to true" do
    
    before(:each) do
      test_log_in(@provider)
    end
    
    describe "GET 'home'" do
      
      it "should be successful" do
        get :home
        response.should be_success
      end
      
      it "should have the right title" do
        get :home
        response.should have_selector("title",  :content => "Training supplier - home")
      end
      
      describe "if the logged in user does not represent a vendor yet" do
        
        it "should display a partial asking the user to add associated vendors" do
          get :home
          response.should have_selector("p", 
              :content => "You're not associated with any training businesses yet")
        end
        
        it "should not have a 'vendor' cookie" do
          get :home
          response.cookies["vendor_id"].should == nil
        end
      end
      
      describe "if the logged-in user represents only one vendor" do
        
        before(:each) do
          @vendor = Factory(:vendor, :country_id => @country.id)
          @representation = Factory(:representation, :user_id => @provider.id, :vendor_id => @vendor.id)
        end
        
        it "should display a partial listing the vendor represented by the user" do
          get :home
          response.should have_selector("li", :content => @vendor.name)
        end
        
        it "should have the vendor.id stored as a cookie" do
          get :home
          response.cookies["vendor_id"].should == "#{@vendor.id}"
        end
      end
      
      describe "if the logged-in user represents more than one vendor" do
        
        before(:each) do
          @vendor = Factory(:vendor, :country_id => @country.id)
          @vendor2 = Factory(:vendor, :name => "Vendor2", :country_id => @country.id,
                                      :address => "Oxford", :email => "vendor2@example.com")
          @representation1 = Factory(:representation, :user_id => @provider.id, :vendor_id => @vendor.id)
          @representation2 = Factory(:representation, :user_id => @provider.id, :vendor_id => @vendor2.id)
          @reps = [@representation1, @representation2]
        end
        
        it "should display a partial listing all the vendors represented by the user" do
          get :home
          @reps.each do |rep|
            response.should have_selector("li", :content => rep.vendor.name)
          end
        end
        
        it "should not have a stored vendor cookie yet" do
          get :home
          response.cookies["vendor_id"].should == nil
        end
      end
    end
    
    
    describe "GET 'resource_group'" do
      
      before(:each) do
        @vendor = Factory(:vendor, :country_id => @country.id)
        @vendor2 = Factory(:vendor, :name => "vendor2", :country_id => @country.id)
      end
      
      describe "if the 'vendor_id' cookie is set" do
        
        before(:each) do
          @representation = Factory(:representation, :user_id => @provider.id, :vendor_id => @vendor2.id)
          test_vendor_cookie(@provider)
          @groups = ["Business", "Job", "Personal", "World", "Fun"]
        end
        
        it "should be successful" do
          get :resource_group
          response.should be_success
        end
      
        it "should have the right title" do
          get :resource_group
          response.should have_selector("title",  :content => "New resource - select a group")
        end
        
        it "should have a radio button for each group" do
          get :resource_group
          @groups.each do |group|
            response.should have_selector("input",  :name => "group",
                                                    :type => "radio",
                                                    :value => "#{group}")
          end
        end
        
        it "should have a link to the new vendor resource path for this vendor" do
          get :resource_group
          response.should have_selector("input", :type => "submit", :value => "Confirm")
        end
      end
      
      describe "if the 'vendor_id' cookie is not set" do
      
        it "should not be successful" do
          get :resource_group
          response.should_not be_success
        end
        
        it "should redirect to the business_home page" do
          get :resource_group
          response.should redirect_to business_home_path
        end  
        
        describe "if the user has no associated vendors" do
          
          it "should warn the user to add at least one vendor" do
            get :resource_group
            flash[:error].should == "First you need to add at least one vendor business." 
          end
          
        end
        
        describe "if the user has associated vendors" do
          
          before(:each) do
            @representation = Factory(:representation, :user_id => @provider.id, :vendor_id => @vendor2.id)
          end 
          
          it "should tell the user to select a vendor" do
            get :resource_group
            flash[:notice].should == "First you need to select one of your vendor businesses."
          end
        end
      end
    end
    
    describe "GET 'duplicate resource to vendor'" do
      
      before(:each) do
        @vendor = Factory(:vendor, :country_id => @country.id, :verified => true)
        @vendor2 = Factory(:vendor, :name => "vendor2", :country_id => @country.id)
        @vendor3 = Factory(:vendor, :name => "vendor3", :country_id => @country.id)
        @vendor4 = Factory(:vendor, :name => "vendor4", :verified => true, :country_id => @country.id)
        @vendor5 = Factory(:vendor, :name => "vendor5", :verified => true, :country_id => @country.id)
        @category = Factory(:category, :user_id => @provider.id, :authorized => true)
        @medium = Factory(:medium, :user_id => @provider.id, :authorized => true)
        @resource1 = Factory(:resource, :vendor_id => @vendor.id, :category_id => @category.id, 
                                    :medium_id => @medium.id)
        @dup_resource1 = Factory(:resource, :vendor_id => @vendor2.id, :category_id => @category.id, 
                                    :medium_id => @medium.id)                            
        @resource2 = Factory(:resource, :name => "Resource2", :vendor_id => @vendor.id, 
                                  :category_id => @category.id, :medium_id => @medium.id)
        @dup_resource2 = Factory(:resource, :name => "Resource2", :vendor_id => @vendor2.id, 
                                  :category_id => @category.id, :medium_id => @medium.id)
      end
      
      describe "if the 'vendor_id' cookie is set" do
        
        before(:each) do
          @representation = Factory(:representation, :user_id => @provider.id, :vendor_id => @vendor.id)
          @representation2 = Factory(:representation, :user_id => @provider.id, :vendor_id => @vendor2.id)
          @representation3 = Factory(:representation, :user_id => @provider.id, :vendor_id => @vendor3.id)
          @representation4 = Factory(:representation, :user_id => @provider.id, :vendor_id => @vendor4.id)
          test_selected_vendor_cookie(@vendor.id)
        end
        
        describe "and if the 'resource_id' cookie is set" do
          
          before(:each) do
            test_resource_cookie(@resource1.id)
          end
          
          it "should be successful" do
            get :duplicate_resource_to_vendor
            response.should be_success
          end
          
          it "should have the right title" do
            get :duplicate_resource_to_vendor
            response.should have_selector("title", :content => "Duplicate resource to vendor")
          end
          
          it "should contain a reference to the resource name" do
            get :duplicate_resource_to_vendor
            response.should have_selector("h4", :content => "Resource: #{@resource1.name}")
          end
          
          it "should list vendors offering the resource" do
            get :duplicate_resource_to_vendor
            response.should have_selector("li", :content => @vendor.name)
            response.should have_selector("li", :content => @vendor2.name)
          end
          
          it "should have a table list for vendors not offering the resource" do
            get :duplicate_resource_to_vendor
            response.should have_selector("td", :content => @vendor3.name)
            response.should have_selector("td", :content => @vendor4.name)
          end
          
          it "should not include in the table list vendors not associated with the user" do
            get :duplicate_resource_to_vendor
            response.should_not have_selector("td", :content => @vendor5.name)
          end
          
          it "should have a 'duplicate' link for vendors not offering the resource" do
            get :duplicate_resource_to_vendor
            response.should have_selector("a", :href => "/duplicate_to_vendor?id=#{@vendor3.id}")
            response.should have_selector("a", :href => "/duplicate_to_vendor?id=#{@vendor4.id}")
          end
          
          it "should not have a 'duplicate' link for vendors offering the resource" do
            get :duplicate_resource_to_vendor
            response.should_not have_selector("a", :href => "/duplicate_to_vendor?id=#{@vendor.id}")
            response.should_not have_selector("a", :href => "/duplicate_to_vendor?id=#{@vendor2.id}")
          end
        end
        
        describe "or if the 'resource_id' cookie is not set" do
          
          it "should not be successful" do
            get :duplicate_resource_to_vendor
            response.should_not be_success
          end
          
        end
      end
      
      describe "if the 'vendor_id' cookie is not set" do
        
        it "should not be successful" do
          get :duplicate_resource_to_vendor
          response.should_not be_success
        end
      end
    end
    
    
    describe "GET 'tickets_menu" do
      
      describe "if the 'vendor_id' cookie is set" do
        
        describe "if the current user is not authorized to use the vendor_id cookie" do
          
          before(:each) do
            @another_user = Factory(:user, :name => "Another", :email => "another@example.com",
                                           :country_id => @country.id)
            @vendor2 = Factory(:vendor, :name => "Another_vendor", :country_id => @country.id)
            @representation2 = Factory(:representation, :user_id => @another_user.id, 
                                       :vendor_id => @vendor2.id)
            test_selected_vendor_cookie(@vendor2.id)
          end
          
          it "should not display successfully" do
            get :tickets_menu
            response.should_not be_success
          end
        end
        
        describe "when the current logged-in user is the correct owner of the vendor_id cookie" do 
          
          before(:each) do
            @vendor = Factory(:vendor, :country_id => @country.id)
            @representation = Factory(:representation, :user_id => @provider.id, :vendor_id => @vendor.id)
            test_selected_vendor_cookie(@vendor.id)
          end
        
          it "should display successfully" do
            get :tickets_menu
            response.should be_success
          end
        
          it "should have the right title" do
            get :tickets_menu
            response.should have_selector("title", :content => "Tickets for Training")
          end
        
          it "should display the vendor's current ticket status" do
            get :tickets_menu
            response.should have_selector("td", :content => "Ticket credits - current balance:")
            response.should have_selector("td", :content => "Credits required for current offers:")
            response.should have_selector("td", :content => "Credits available:")
          end
        
          it "should have links which apply regardless of issues status" do
            #get :tickets_menu
            #response.should have_selector("a", :href => t4t_intro_path, :content => "How the scheme works")
            #response.should have_selector("a", :content => "Purchase new ticket credits")
            #response.should have_selector("a", :href => vendor_account_path, :content => "Your account")
            pending "until purchasing ticket credits is designed"
          end
        
          describe "and the vendor has never issued tickets" do 
          
            it "should promote the value of using tickets if the vendor has never issued tickets" do
              get :tickets_menu
              response.should have_selector(".announcement", :content => "Try our unique 'Tickets' scheme")
            end
        
          end
        
          describe "and the vendor has not listed any resources" do
          
            it "should have an 'Issue tickets' link" do
              get :tickets_menu
              response.should have_selector("a", :href => program_selection_path,
                                               :content => "Issue tickets")
            end
          
            it "should not have a 'Current ticket offers' link" do
              get :tickets_menu
              response.should_not have_selector("a", :content => "Current ticket offers")
            end
          
            it "should not have a 'Confirm a sale' link" do
              get :tickets_menu
              response.should_not have_selector("a", :content => "Confirm a sale")
            end
          
            it "should not have a 'History' link" do
              #get :tickets_menu
              #response.should_not have_selector("a", :content => "History")
              pending "complete when History link is designed"
            end
          end
        
          describe "and the vendor has issued tickets that have now expired" do
          
            before(:each) do
              @fee = Factory(:fee)
              @medium = Factory(:medium, :user_id => @user.id, :scheduled => true)
              @category = Factory(:category, :user_id => @user.id, :authorized => true)
              @resource = Factory(:resource, :vendor_id => @vendor.id, :category_id => @category.id, 
                                   :medium_id => @medium.id)
              @old_item = Factory(:item, :resource_id => @resource.id, :currency => "GBP", :cents => 1500,
                                          :start => Date.today - 30.days, :finish => Date.today)
              @issue = Factory(:issue, :item_id => @old_item.id, :vendor_id => @vendor.id, 
                                     :user_id => @user.id, :fee_id => @fee.id, 
                                     :expiry_date => Date.today - 31.days)
            
            end
          
            it "should not carry the 'never issued tickets' promotion" do
              get :tickets_menu
              response.should_not have_selector(".announcement", :content => "Try our unique 'Tickets' scheme")
            end
          
            it "should include a 'History' link" do
              #get :tickets_menu
              #response.should have_selector("a", :content => "History")
              pending "complete when history link is built"
            end  
          
            describe "but has no current ticketable resources" do
            
              it "should have an 'Issue tickets' link" do
                get :tickets_menu
                response.should have_selector("a", :href => program_selection_path,
                                               :content => "Issue tickets")
              end
          
              it "should not have a 'Current ticket offers' link" do
                get :tickets_menu
                response.should_not have_selector("a", :content => "Current ticket offers")
              end
          
              it "should not have a 'Confirm a sale' link" do
                get :tickets_menu
                response.should_not have_selector("a", :content => "Confirm a sale")
              end
            end
          
            describe "and also has ticketable events but no ticketable resources" do
            
              before(:each) do
                @new_event = Factory(:item, :resource_id => @resource.id, :currency => "GBP", :cents => 1500)
                @new_event_issue = Factory(:issue, :item_id => @new_event.id, :vendor_id => @vendor.id, 
                                     :user_id => @user.id, :fee_id => @fee.id, 
                                     :expiry_date => Date.today + 6.days)
              end
            
              it "should have an 'Issue tickets' link" do
                get :tickets_menu
                response.should have_selector("a", :href => program_selection_path,
                                               :content => "Issue tickets")
              end
            
              it "should not have a link to 'resource selection" do
                get :tickets_menu
                response.should_not have_selector("a", :href => resource_selection_path)
              end
              
              it "should have a 'Current ticket offers' link" do
                get :tickets_menu
                response.should have_selector("a", :href => business_offers_path,
                                :content => "Current ticket offers")
              end
          
              it "should have a 'Confirm a sale' link" do
                #get :tickets_menu
                #response.should have_selector("a", :content => "Confirm a sale")
                pending "complete when 'confirm a sale is designed"
              end
            end
          
            describe "and also has ticketable resources but no ticketable events" do
            
              before(:each) do
                @medium_non_event = Factory(:medium, :medium => "Book", :user_id => @user.id, 
                                                   :authorized => true, :scheduled => false)
              @resource_non_event = Factory(:resource, :vendor_id => @vendor.id, :category_id => @category.id, 
                                   :medium_id => @medium_non_event.id, :name => "A Book")
                @new_resource = Factory(:item, :resource_id => @resource_non_event.id, :currency => "GBP", 
                                          :cents => 1500, :finish => nil, :venue => "Publisher")
                @new_resource_issue = Factory(:issue, :item_id => @new_resource.id, :vendor_id => @vendor.id, 
                                     :user_id => @user.id, :fee_id => @fee.id, 
                                     :expiry_date => Date.today + 30.days)
              
              end
            
              it "should not have an 'Issue tickets' link" do
                get :tickets_menu
                response.should_not have_selector("a", :href => program_selection_path)
              end
            
              it "should have a link to 'resource selection" do
                get :tickets_menu
                response.should have_selector("a", :href => resource_selection_path,
                                                 :content => "Issue tickets")
              end
              
              it "should have a 'Current ticket offers' link" do
                get :tickets_menu
                response.should have_selector("a", :href => business_offers_path,
                                :content => "Current ticket offers")
              end
          
              it "should have a 'Confirm a sale' link" do
                #get :tickets_menu
                #response.should have_selector("a", :content => "Confirm a sale")
                pending "complete when 'confirm a sale is designed"
              end
            end
          
            describe "and also has both ticketable and non ticketable resources" do
            
              before(:each) do
                @new_event = Factory(:item, :resource_id => @resource.id, :currency => "GBP", :cents => 1500)
                @new_event_issue = Factory(:issue, :item_id => @new_event.id, :vendor_id => @vendor.id, 
                                     :user_id => @user.id, :fee_id => @fee.id, 
                                     :expiry_date => Date.today + 6.days)
                @medium_non_event = Factory(:medium, :medium => "Book", :user_id => @user.id, 
                                                   :authorized => true, :scheduled => false)
              @resource_non_event = Factory(:resource, :vendor_id => @vendor.id, :category_id => @category.id, 
                                   :medium_id => @medium_non_event.id, :name => "A Book")
                @new_resource = Factory(:item, :resource_id => @resource_non_event.id, :currency => "GBP", 
                                          :cents => 1500, :finish => nil, :venue => "Publisher")
                @new_resource_issue = Factory(:issue, :item_id => @new_resource.id, :vendor_id => @vendor.id, 
                                     :user_id => @user.id, :fee_id => @fee.id, 
                                     :expiry_date => Date.today + 30.days)
              
              end
            
              it "should have an 'Issue tickets' link" do
                get :tickets_menu
                response.should have_selector("a", :href => program_selection_path,
                                                     :content => "Issue tickets")
              end
            
              it "should have a link to 'resource selection" do
                get :tickets_menu
                response.should have_selector("a", :href => resource_selection_path,
                                                 :content => "other")
              end
            
              it "should have a separate link to events only" do
                get :tickets_menu
                response.should have_selector("a", :href => program_selection_path,
                                                     :content => "(events)")
              end
              
              it "should have a 'Current ticket offers' link" do
                get :tickets_menu
                response.should have_selector("a", :href => business_offers_path,
                                :content => "Current ticket offers")
              end
          
              it "should have a 'Confirm a sale' link" do
                #get :tickets_menu
                #response.should have_selector("a", :content => "Confirm a sale")
                pending "complete when 'confirm a sale is designed"
              end
            
              describe "unless all the ticketable events are filled" do
              
                before(:each) do
                  @new_event.update_attribute(:filled, true)
                end
              
                it "should have an 'Issue tickets' linking to resource path" do
                  get :tickets_menu
                  response.should have_selector("a", :href => resource_selection_path,
                                                     :content => "Issue tickets")
                end
              end
            
              describe "unless all the ticketable non-events are 'filled'" do
              
                before(:each) do
                  @new_resource.update_attribute(:filled, true)
                end
              
                it "should_not have a link to the resource_selection_path" do
                  get :tickets_menu
                  response.should_not have_selector("a", :href => resource_selection_path)
                end
              end
            end
          end
        
          it "should have a display pane for an admin success story about tickets" do
            pending "still need to write - add in right margin"
          end
        
          it "should warn the vendor if no tickets are available" do
            pending "perhaps do"
          end
        
          it "should display an alert if there are no current ticket offers" do
            pending "perhaps do"
          end
        end
      end
      
      describe "if the vendor_id cookie is not set" do
        
        before(:each) do
            @vendor = Factory(:vendor, :country_id => @country.id)
            @representation = Factory(:representation, :user_id => @provider.id, :vendor_id => @vendor.id)
          end
        
        it "should not display successfully" do
          get :tickets_menu
          response.should_not be_success
        end
        
        it "should redirect to the business home path" do
          get :tickets_menu
          response.should redirect_to business_home_path
        end
      end
       
    end
    
    describe "GET 'program_selection'" do 
     
      describe "if the 'vendor_id' cookie is set" do
        
        describe "if the current user is not authorized to use the vendor_id cookie" do
          
          before(:each) do
            @another_user = Factory(:user, :name => "Another", :email => "another@example.com",
                                           :country_id => @country.id)
            @vendor2 = Factory(:vendor, :name => "Another_vendor", :country_id => @country.id)
            @representation2 = Factory(:representation, :user_id => @another_user.id, 
                                       :vendor_id => @vendor2.id)
            test_selected_vendor_cookie(@vendor2.id)
          end
          
          it "should not display successfully" do
            get :program_selection
            response.should_not be_success
          end
          
          it "should display a warning message" do
            get :program_selection
            flash[:notice].should =~ /Permission denied/
          end
        end
        
        describe "when the current logged-in user is the correct owner of the vendor_id cookie" do 
          
          before(:each) do
            @vendor = Factory(:vendor, :country_id => @country.id)
            @representation = Factory(:representation, :user_id => @provider.id, :vendor_id => @vendor.id)
            
            @user3 = Factory(:user, :name => "User_3", :email => "user3@example.com", 
                                   :country_id => @country.id)
            @vendor2 = Factory(:vendor, :name => "Vendor2", :country_id => @country.id)
            @representation2 = Factory(:representation, :user_id => @user3.id, :vendor_id => @vendor2.id)
            
            
            test_selected_vendor_cookie(@vendor.id)
            
            @fee = Factory(:fee)    
            @medium = Factory(:medium, :user_id => @user.id, :scheduled => true)
            @category = Factory(:category, :user_id => @user.id, :authorized => true)
            @resource = Factory(:resource, :vendor_id => @vendor.id, :category_id => @category.id, 
                                       :medium_id => @medium.id)
            @other_user_resource = Factory(:resource, :name => "Other_resource", :vendor_id => @vendor2.id,
                                       :category_id => @category.id, :medium_id => @medium.id)          
            @event_1 = Factory(:item, :resource_id => @resource.id, :currency => "GBP", :cents => 1500)
            @event_2 = Factory(:item, :resource_id => @resource.id, :currency => "GBP", :cents => 1500,
                           :start => Date.today - 20.days, :finish => Date.today + 40.days)
            @event_1_issue = Factory(:issue, :item_id => @event_1.id, :vendor_id => @vendor.id, 
                                   :user_id => @user.id, :fee_id => @fee.id, 
                                   :expiry_date => Date.today + 6.days)
            @event_finished = Factory(:item, :resource_id => @resource.id, :currency => "GBP", :cents => 1500,
                           :start => Date.today - 20.days, :finish => Date.today - 1.day, :venue => "There")
            @event_filled = Factory(:item, :resource_id => @resource.id, :currency => "GBP", :cents => 1500,
                           :start => Date.today + 2.days, :finish => Date.today + 15.days, :filled => true)
            @event_other_user = Factory(:item, :resource_id => @other_user_resource.id, :currency => "GBP",
                           :cents => 15000, :start => Date.today, :finish => Date.today + 40.days)    
            @events = [@event_1, @event_2]
          end
          
          describe "but the vendor has no ticket credits" do
            
            it "should not display successfully" do
              get :program_selection
              response.should_not be_success
            end
            
            it "should have a flash warning" do
              get :program_selection
              flash[:notice].should =~ /To continue, please place an order for more tickets/
            end
            
            it "should redirect to the vendor account path" do
              get :program_selection
              response.should redirect_to vendor_account_path
            end
          end
          
          describe "and the vendor has ticket credits" do
            
            before(:each) do
              @credit = Factory(:credit, :vendor_id => @vendor.id)
            end
            
            it "should display successfully" do
              get :program_selection
              response.should be_success
            end
        
            it "should have the right title" do
              get :program_selection
              response.should have_selector("title", :content => "Ticket issue: select an event")
            end
            
            it "should display the vendor name" do
              get :program_selection
              response.should have_selector("h4", :content => @vendor.name)
            end
            
            it "should list all the vendor's bookable current and future events, with edit links" do
              get :program_selection
              @events.each do |event|
                response.should have_selector("a", :href => new_item_issue_path(event.id),
                                                   :content => event.resource.name)
              end
            end
            
            it "should not list completed events" do
              get :program_selection
              response.should_not have_selector("a", :content => @event_finished.ref.to_s)
            end
            
            it "should not include fully-booked events" do
              get :program_selection
              response.should_not have_selector("a",  :content => @event_filled.ref.to_s)
            end
            
            it "should not list current and future events from other vendors" do
              get :program_selection
              response.should_not have_selector("a", :content => @event_other_user.resource.name)
            end
            
            it "should have a clickable link with the event's reference number" do
              get :program_selection
              response.should have_selector("a", :href => new_item_issue_path(@event_1.id),
                                        :content => @event_1.ref.to_s)
            end
            
            it "should specify the start-date for each listed event" do
              get :program_selection
              @events.each do |event|
                response.should have_selector("td", :content => event.start.strftime('%d-%b-%y'))
              end
            end
            
            it "should specify the end-date for each listed event" do
              get :program_selection
              @events.each do |event|
                response.should have_selector("td", :content => event.finish.strftime('%d-%b-%y'))
              end
            end
            
            it "should include the format for each listed event" do
              get :program_selection
              @events.each do |event|
                response.should have_selector("td", :content => event.resource.medium.medium)
              end
            end
            
            it "should include the venue for each listed event" do
              get :program_selection
              @events.each do |event|
                response.should have_selector("td", :content => event.venue)
              end
            end
            
            it "should have a clickable link to any previous ticket issues if there have been any" do
              get :program_selection
              response.should have_selector("a", :href => item_issues_path(@event_1))
                                                
            end
            
            it "should not display a clickable link to other ticket issues if there have been none" do
              get :program_selection
              response.should_not have_selector("a", :href => item_issues_path(@event_2)) 
            end
            
            it "should display the current number of ticket credits available" do
              get :program_selection
              response.should have_selector(".h_tag", :content => "38 ticket credits available")
            end
              
            it "should not have a link to the vendor's non-event resources if there are none" do
              get :program_selection
              response.should_not have_selector("a",  :href => resource_selection_path,
                                                      :content => "other resources")
            end
            
            it "should have a 'Return to the tickets menu' link" do
              get :program_selection
              response.should have_selector("a", :href => tickets_menu_path,
                                                 :content => "Return to Tickets menu")
            end
            
            describe "when the vendor also has ticketable non-event resources" do
              
              before(:each) do
                @medium_non_event = Factory(:medium, :medium => "Book", :user_id => @user.id, 
                                                   :authorized => true, :scheduled => false)
                @resource_non_event = Factory(:resource, :vendor_id => @vendor.id, 
                                   :category_id => @category.id, 
                                   :medium_id => @medium_non_event.id, :name => "A Book")
                @new_resource = Factory(:item, :resource_id => @resource_non_event.id, :currency => "GBP", 
                                          :cents => 1500, :finish => nil, :venue => "Publisher")
              end
              
              it "should not list non-event resources" do
                get :program_selection
                response.should_not have_selector("a", :content => @new_resource.resource.name)
              end
              
              it "should have a link to the vendor's ticketable non-event resources" do
                get :program_selection
                response.should have_selector("a",  :href => resource_selection_path,
                                                      :content => "other resources")
              end
            end
          end
          
        end
      end
      
      describe "if the vendor_id cookie is not set" do
        
        before(:each) do
            @vendor = Factory(:vendor, :country_id => @country.id)
            @representation = Factory(:representation, :user_id => @provider.id, :vendor_id => @vendor.id)
          end
        
        it "should not display successfully" do
          get :program_selection
          response.should_not be_success
        end
        
        it "should redirect to the business home page" do
          get :program_selection
          response.should redirect_to business_home_path
        end
      end
        
      
      
    end
    
    describe "GET 'resource_selection'" do 
     
      describe "if the 'vendor_id' cookie is set" do
        
        describe "if the current user is not authorized to use the vendor_id cookie" do
          
          before(:each) do
            @another_user = Factory(:user, :name => "Another", :email => "another@example.com",
                                           :country_id => @country.id)
            @vendor2 = Factory(:vendor, :name => "Another_vendor", :country_id => @country.id)
            @representation2 = Factory(:representation, :user_id => @another_user.id, 
                                       :vendor_id => @vendor2.id)
            test_selected_vendor_cookie(@vendor2.id)
          end
          
          it "should not display successfully" do
            get :resource_selection
            response.should_not be_success
          end
          
          it "should display a warning message" do
            get :resource_selection
            flash[:notice].should =~ /Permission denied/
          end
        end
        
        describe "when the current logged-in user is the correct owner of the vendor_id cookie" do 
          
          before(:each) do
            @vendor = Factory(:vendor, :country_id => @country.id)
            @representation = Factory(:representation, :user_id => @provider.id, :vendor_id => @vendor.id)
            
            @user3 = Factory(:user, :name => "User_3", :email => "user3@example.com", 
                                   :country_id => @country.id)
            @vendor2 = Factory(:vendor, :name => "Vendor2", :country_id => @country.id)
            @representation2 = Factory(:representation, :user_id => @user3.id, :vendor_id => @vendor2.id)
            
            
            test_selected_vendor_cookie(@vendor.id)
            
            @fee = Factory(:fee)    
            @medium = Factory(:medium, :user_id => @user.id, :scheduled => false)
            @category = Factory(:category, :user_id => @user.id, :authorized => true)
            @resource_1 = Factory(:resource, :vendor_id => @vendor.id, :category_id => @category.id, 
                                       :medium_id => @medium.id)
            @resource_2 = Factory(:resource, :vendor_id => @vendor.id, :category_id => @category.id, 
                                       :medium_id => @medium.id, :name => "Resource_2")
            @resource_3 = Factory(:resource, :vendor_id => @vendor.id, :category_id => @category.id, 
                                       :medium_id => @medium.id, :name => "Resource_NA")      
            @other_user_resource = Factory(:resource, :name => "Other resource", :vendor_id => @vendor2.id,
                                       :category_id => @category.id, :medium_id => @medium.id)          
            @item_1 = Factory(:item, :resource_id => @resource_1.id, :currency => "GBP", :cents => 1500,
                           :start => Date.today - 20.days, :finish => nil)
            @item_2 = Factory(:item, :resource_id => @resource_2.id, :currency => "GBP", :cents => 3000,
                           :start => Date.today - 40.days, :finish => nil)
            @item_3 = Factory(:item, :resource_id => @resource_3.id, :currency => "GBP", :cents => 2000,
                           :start => Date.today - 40.days, :finish => nil, :filled => true)
            
            @issue_1 = Factory(:issue, :item_id => @item_1.id, :vendor_id => @vendor.id, 
                                   :user_id => @user.id, :fee_id => @fee.id, 
                                   :expiry_date => Date.today + 30.days)
            @issue_2 = Factory(:issue, :item_id => @item_2.id, :vendor_id => @vendor.id, 
                                   :user_id => @user.id, :fee_id => @fee.id, 
                                   :expiry_date => Date.today - 30.days)                     
           
            @other_user_item = Factory(:item, :resource_id => @other_user_resource.id, :currency => "GBP",
                                           :cents => 15000, :start => Date.today, :finish => nil)    
            
            @items = [@item_1, @item_2]
          end
          
          describe "but the vendor has no ticket credits" do
            
            it "should not display successfully" do
              get :resource_selection
              response.should_not be_success
            end
            
            it "should have a flash warning" do
              get :resource_selection
              flash[:notice].should =~ /To continue, please place an order for more tickets/
            end
            
            it "should redirect to the vendor account path" do
              get :resource_selection
              response.should redirect_to vendor_account_path
            end
          end
          
          describe "and the vendor has ticket credits" do
            
            before(:each) do
              @credit = Factory(:credit, :vendor_id => @vendor.id)
            end
            
            it "should display successfully" do
              get :resource_selection
              response.should be_success
            end
        
            it "should have the right title" do
              get :resource_selection
              response.should have_selector("title", :content => "Ticket issue: select a resource")
            end
            
            it "should display the vendor name" do
              get :resource_selection
              response.should have_selector("h4", :content => @vendor.name)
            end
            
            it "should list names of all the vendor's bookable non-event resources, with edit links" do
              get :resource_selection
              @items.each do |item|
                response.should have_selector("a", :href => new_item_issue_path(item.id),
                                                   :content => item.resource.name)
              end
            end
            
            it "should not list items that are not available" do
              get :resource_selection
              response.should_not have_selector("a", :content => @item_3.ref.to_s)
            end
            
            it "should not list current and future events from other vendors" do
              get :resource_selection
              response.should_not have_selector("a", :content => @other_user_item.resource.name)
            end
            
            it "should have a clickable link with the event's reference number" do
              get :resource_selection
              response.should have_selector("a", :href => new_item_issue_path(@item_1.id),
                                        :content => @item_1.ref.to_s)
            end
            
            it "should specify the release-date for each listed event" do
              get :resource_selection
              @items.each do |item|
                response.should have_selector("td", :content => item.start.strftime('%d-%b-%y'))
              end
            end
            
            it "should specify the format for each listed event" do
              get :resource_selection
              @items.each do |item|
                response.should have_selector("td", :content => item.resource.medium.medium)
              end
            end
            
            it "should have a clickable link to any previous ticket issues if there have been any" do
              get :resource_selection
              @items.each do |item|
                response.should have_selector("a", :href => item_issues_path(item.id))
              end                               
            end
            
            it "should not display a clickable link to other ticket issues if there have been none" do
              get :resource_selection
              response.should_not have_selector("a", :href => item_issues_path(@item_3)) 
            end
            
            it "should display the current number of ticket credits available" do
              get :resource_selection
              response.should have_selector(".h_tag", :content => "38 ticket credits available")
            end
              
            it "should not have a link to the vendor's event resources if there are none" do
              get :resource_selection
              response.should_not have_selector("a",  :href => program_selection_path,
                                                      :content => "events")
            end
            
            it "should have a 'Return to the tickets menu' link" do
              get :resource_selection
              response.should have_selector("a", :href => tickets_menu_path,
                                                 :content => "Return to Tickets menu")
            end
            
            describe "when the vendor also has ticketable event resources" do
              
              before(:each) do
                @medium_event = Factory(:medium, :medium => "Book", :user_id => @user.id, 
                                                   :authorized => true, :scheduled => true)
                @resource_event = Factory(:resource, :vendor_id => @vendor.id, 
                                   :category_id => @category.id, 
                                   :medium_id => @medium_event.id, :name => "A Class")
                @new_event = Factory(:item, :resource_id => @resource_event.id, :currency => "GBP", 
                                          :cents => 1500, :venue => "Classroom")
              end
              
              it "should not list event resources" do
                get :resource_selection
                response.should_not have_selector("a", :content => @new_event.resource.name)
              end
              
              it "should have a link to the vendor's ticketable event resources" do
                get :resource_selection
                response.should have_selector("a",  :href => program_selection_path,
                                                      :content => "events")
              end
            end
          end
          
        end
      end
      
      describe "if the vendor_id cookie is not set" do
        
        before(:each) do
          @vendor = Factory(:vendor, :country_id => @country.id)
          @representation = Factory(:representation, :user_id => @provider.id, :vendor_id => @vendor.id)
        end
        
        it "should not display successfully" do
          get :program_selection
          response.should_not be_success
        end
        
        it "should redirect to the business home page" do
          get :program_selection
          response.should redirect_to business_home_path
        end
      end
        
      
      
    end               
  end
end
