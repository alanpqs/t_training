require 'spec_helper'

describe PagesController do
  render_views

  describe "GET 'home'" do
    it "should be successful" do
      get 'home'
      response.should be_success
    end
    
    it "should have the right title" do
      get 'home'
      response.should have_selector("title",
              :content => "Tickets for Training | Home"
      )
    end
  end

  describe "GET 'why_register'" do
    it "should be successful" do
      get 'why_register'
      response.should be_success
    end
    
    it "should have the right title" do
      get 'why_register'
      response.should have_selector("title",
              :content => "Tickets for Training | Why Register"
      )
    end
  end
  
  describe "GET 'about'" do
    it "should be successful" do
      get 'about'
      response.should be_success
    end
    
    it "should have the right title" do
      get 'about'
      response.should have_selector("title",
              :content => "Tickets for Training | About"
      )
    end
  end

end
