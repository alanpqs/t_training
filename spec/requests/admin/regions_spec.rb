require 'spec_helper'

describe "Regions" do

  before(:each) do
    user = Factory(:user, :admin => true)
    @attrs = ["Africa", "Asia", "America"]
    @attrs.each do |attr|
      Region.create!(:region => attr)
    end
    #@region = Region.find_by_region("Europe")
    integration_log_in(user)
  end

  describe "links on the Regions index page" do
    
    it "should redirect to the correct edit page when the Region is clicked" do
      @attrs.each do |attr|
        visit admin_regions_path
        click_link "Edit #{attr}"
        response.should have_selector("title", :content => "Edit region")
        response.should have_selector("input", :value => attr)
      end
    end
  end  
end
