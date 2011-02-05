require 'spec_helper'

describe ItemsController do
  
  
  render_views
  
  require 'money'
  
  
  before(:each) do
    @region = Factory(:region)
    @country = Factory(:country, :name => "United Kingdom", :currency_code => "GBP", :region_id => @region.id)
    @user = Factory(:user, :country_id => @country.id, :vendor => true)
    @vendor = Factory(:vendor, :country_id => @country.id, :verified => true)
    @representation = Factory(:representation, :user_id => @user, :vendor_id => @vendor)
    @medium = Factory(:medium, :user_id => @user.id, :scheduled => true)
    @category = Factory(:category, :user_id => @user.id, :authorized => true)
    @resource = Factory(:resource, :vendor_id => @vendor.id, :category_id => @category.id, 
                                   :medium_id => @medium.id)
    @item1 = Factory(:item, :resource_id => @resource.id, :currency => "GBP", :cents => 1500)
    @item2 = Factory(:item, :resource_id => @resource.id, :reference => "ABC1", :days => "Tue/Wed/Thu",
                            :time_of_day => "Evenings", :start => Time.now - 2.days,
                            :finish => Time.now + 10.days,
                            :currency => "GBP", :cents => 2000)
    @item3 = Factory(:item, :resource_id => @resource.id, :days => "Tue/Wed",
                            :start => Time.now - 10.days, :finish => Time.now - 2.days,
                            :currency => "GBP", :cents => 2250)                        
                            
    @wrongvendor_user = Factory(:user, :email => "wronguser@example.com", 
                                       :country_id => @country.id, :vendor => true)
    @xvendor = Factory(:vendor, :country_id => @country.id, :verified => true, :name => "Wrong Vendor")
    @xrepresentation = Factory(:representation, :user_id => @wrongvendor_user.id, :vendor_id => @xvendor.id)
    @xresource = Factory(:resource, :vendor_id => @xvendor.id, :category_id => @category.id, 
                                    :medium_id => @medium.id, :name => "X resource")
    @item_x = Factory(:item, :resource_id => @xresource.id)
  end
    
  describe "for non-logged-in users" do
    
  end
  
  describe "for logged-in non-vendors" do
    
    before(:each) do
      @nonvendor_user = Factory(:user, :email => "nonvendor@example.com", 
                                       :country_id => @country.id, :vendor => false) 
      test_log_in(@nonvendor_user)
    end

  end
  
  describe "for the wrong logged-in user-vendor" do

    before(:each) do
      test_log_in(@wrongvendor_user)
    end  
  end
  
  describe "for the right logged-in user-vendor" do
    
    describe "and a verified vendor-business" do
    
      before(:each) do
        test_log_in(@user)
        test_selected_vendor_cookie(@vendor)
        test_resource_cookie(@resource)        
      end
    
      describe "when the resource is the one currently selected" do
        
        describe "GET 'index'" do
          
          it "should be successful" do
            get :index, :resource_id => @resource.id
            response.should be_success
          end
          
          it "should have the correct title" do
            get :index, :resource_id => @resource.id
            response.should have_selector("title", :content => "Current & future events")
          end
          
          it "should display the correct vendor name" do
            get :index, :resource_id => @resource.id
            response.should have_selector("h4", :content => @vendor.name)
          end
          
          it "should display the correct Resource name" do
            get :index, :resource_id => @resource.id
            response.should have_selector("h4", :content => @resource.name)
          end
          
          it "should display all current and future events for the selected resource, with a 'show' link" do
            get :index, :resource_id => @resource.id
            response.should have_selector("a", :href => item_path(@item1))
            response.should have_selector("a", :href => item_path(@item2))
          end
          
          it "should not display past events for the selected resource" do
            get :index, :resource_id => @resource.id
            response.should_not have_selector("a", :href => item_path(@item3))
          end
          
          it "should not display current and future events for a difference resource" do
            get :index, :resource_id => @resource.id
            response.should_not have_selector("a", :href => item_path(@item_x))
          end
          
          it "should display the correct reference number if the 'reference' field is filled" do
            get :index, :resource_id => @resource.id
            response.should have_selector("td", :content => "ABC1")
          end
          
          it "should display an automated reference number if the 'reference' field is not filled" do
            get :index, :resource_id => @resource.id
            response.should have_selector("td", :content => "1")
          end
          
          it "should display a start-date for each element" do
            get :index, :resource_id => @resource.id
            response.should have_selector("td", :content => "#{(Time.now + 7.days).strftime('%d-%b-%y')}")
            response.should have_selector("td", :content => "#{(Time.now - 2.days).strftime('%d-%b-%y')}")
          end
          
          it "should display an end-date for each element" do
            get :index, :resource_id => @resource.id
            response.should have_selector("td", :content => "#{(Time.now + 10.days).strftime('%d-%b-%y')}")
            response.should have_selector("td", :content => "#{(Time.now + 34.days).strftime('%d-%b-%y')}")
          end
          
          it "should display the venue for each element" do
            get :index, :resource_id => @resource.id
            response.should have_selector("td", :content => "Holiday Inn, Cambridge")
          end
          
          it "should display the correctly formatted local price for each element" do
            get :index, :resource_id => @resource.id
            response.should have_selector("td", :content => "15.00")
            response.should have_selector("td", :content => "20.00")
            #Not tested for pound symbol
          end
          
          it "should have a 'delete' link for each element" do
            @items = [@item1, @item2]
            get :index, :resource_id => @resource.id
            @items.each do |item|
              response.should have_selector("a", :href => item_path(item),
                                               :title => "Delete event #{item.ref}, but not the resource")
            end
          end
          
          it "should paginate items" do
            31.times do
              @items = []
              @items << Factory(:item, :resource_id => @resource.id, :currency => "GBP", :cents => 1500, 
                                :start => Factory.next(:start),
                                :finish => Factory.next(:finish))
            end
            get :index, :resource_id => @resource.id
            response.should have_selector("div.pagination")
            response.should have_selector("span.disabled", :content => "Previous")
            response.should have_selector("a",  :href => "/resources/#{@resource.id}/items?page=2",
                                                :content => "2")
            response.should have_selector("a",  :href => "/resources/#{@resource.id}/items?page=2",
                                                :content => "Next")
          end
          
          it "should have a link to return to the main Resource page" do
            get :index, :resource_id => @resource.id
            response.should have_selector("a", :href => resource_path(@resource), 
                                            :content => "main Resource page")
          end
        end

        describe "GET 'new'" do
          it "should be successful" do
            get :new, :resource_id => @resource.id
            response.should be_success
          end
          
          it "should have the right title" do
            get :new, :resource_id => @resource.id
            response.should have_selector("title", :content => "Schedule a new event")
          end
          
          it "should display the correct vendor" do
            get :new, :resource_id => @resource.id
            response.should have_selector("h4", :content => @vendor.name)
          end
          
          it "should display the correct resource" do
            get :new, :resource_id => @resource.id
            response.should have_selector("h4", :content => @resource.name)
          end
          
          it "should have an empty text box for 'reference'" do
            get :new, :resource_id => @resource.id
            response.should have_selector("input", :name => "item[reference]",
                                                   :content => "")
          end
          
          it "should have select options for the start-date" do
            get :new, :resource_id => @resource.id
            response.should have_selector("select", :name => "item[start(1i)]")
            response.should have_selector("select", :name => "item[start(2i)]")
            response.should have_selector("select", :name => "item[start(3i)]")
          end
          
          it "should have select options for the end-date" do
            get :new, :resource_id => @resource.id
            response.should have_selector("select", :name => "item[finish(1i)]")
            response.should have_selector("select", :name => "item[finish(2i)]")
            response.should have_selector("select", :name => "item[finish(3i)]")
          end
          
          it "should have a set of check-boxes for 'Attendance days required" do
            get :new, :resource_id => @resource.id
            response.should have_selector("input", :name => "item[day_mon]", :type => "checkbox")
            response.should have_selector("input", :name => "item[day_tue]", :type => "checkbox")
            response.should have_selector("input", :name => "item[day_wed]", :type => "checkbox")
            response.should have_selector("input", :name => "item[day_thu]", :type => "checkbox")
            response.should have_selector("input", :name => "item[day_fri]", :type => "checkbox")
            response.should have_selector("input", :name => "item[day_sat]", :type => "checkbox")
            response.should have_selector("input", :name => "item[day_sun]", :type => "checkbox")
          end
          
          it "should have a select option for 'Time of day' with the correct options" do
            get :new, :resource_id => @resource.id
            response.should have_selector("select", :name => "item[time_of_day]", :content => "Please select")
            response.should have_selector("option", :value => "Mornings")
            response.should have_selector("option", :value => "Afternoons")
            response.should have_selector("option", :value => "Evenings")
            response.should have_selector("option", :value => "All day")
          end
          
          it "should have a text-box for price, defaulting to '0.00'" do
            get :new, :resource_id => @resource.id
            response.should have_selector("input", :name => "item[price]", :value => "0.00")
          end
          
          it "should display the correct local currency symbol" do
            pending "not sure how to test currency symbol"
          end
          
          it "should have an empty text-box for 'Venue'" do
            get :new, :resource_id => @resource.id
            response.should have_selector("input", :name => "item[venue]")
          end
          
          it "should have an empty text-area for 'Notes'" do
            get :new, :resource_id => @resource.id
            response.should have_selector("textarea", :name => "item[notes]")
          end
          
          it "should have a set of radio-buttons for 'Availability', defaulting to 'Places available'" do
            get :new, :resource_id => @resource.id
            response.should have_selector("input", :name => "item[filled]", :value => "true", 
                                                   :type => "radio")
            response.should have_selector("input", :name => "item[filled]", :value => "false", 
                                                   :type => "radio", :checked => "checked")
          end
          
          it "should have a 'Create event' submit button" do
            get :new, :resource_id => @resource.id
            response.should have_selector("input", :name => "commit", 
                                                   :type => "submit", :value => "Create event")
          end
          
          it "should have a link back to the main Resource page, dropping all changes" do
            get :new, :resource_id => @resource.id
            response.should have_selector("a", :href => resource_path(@resource), 
                                             :content => "drop addition - back to main Resource page")
          end 
            
        end
      end
      
      describe "when the resource is not the one currently selected" do
        
      end
    end
    
    describe "and a non-verified vendor-business" do
      
    end
  end
end
