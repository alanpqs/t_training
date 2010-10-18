require 'spec_helper'

describe PagesController do

  describe "GET 'home'" do
    it "should be successful" do
      get 'home'
      response.should be_success
    end
  end

  describe "GET 'why_register'" do
    it "should be successful" do
      get 'why_register'
      response.should be_success
    end
  end

end
