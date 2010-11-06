require 'spec_helper'

describe CurrenciesController do
  
  render_views

  describe "GET 'index'" do
    it "should be successful" do
      get :index
      response.should be_success
    end
    
    it "should have the correct title" do
      get :index
      response.should have_selector("title", :content => "Currencies")
    end
  end

  #describe "GET 'show'" do
  #  it "should be successful" do
  #    get :show
  #    response.should be_success
  #  end
    
  #  it "should have the right title" do
  #    get :show
  #    response.should have_selector("title", :content => "Currency")
  #  end
  #end

end
