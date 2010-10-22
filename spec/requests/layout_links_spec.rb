require 'spec_helper'

describe "LayoutLinks" do
  it "should have a Home page at '/'" do
    get '/'
    response.should have_selector('title', :content => "Home")
  end
  
  it "should have a Why Register page at '/why_register'" do
    get '/why_register'
    response.should have_selector('title', :content => "Why Register")
  end
  
  it "should have an About page at '/about'" do
    get '/about'
    response.should have_selector('title', :content => "About")
  end
  
  it "should have an FAQs page at '/faqs'" do
    get '/faqs'
    response.should have_selector('title', :content => "FAQs")
  end
  
  it "should have a Find training page at '/find_training'" do
    get '/find_training'
    response.should have_selector('title', :content => "Find Training") 
  end
  
  it "should have a Signup page at '/signup'" do
    get '/signup'
    response.should have_selector('title', :content => "Signup")
  end
  
  it "should have a Login page at '/login'" do
    get '/login'
    response.should have_selector('title', :content => "Login")
  end
  
  it "should have a Buyers page at '/buyers'" do
    get '/buyers'
    response.should have_selector('title', :content => "Buyers")
  end
  
  it "should have a Sellers page at '/sellers'" do
    get '/sellers'
    response.should have_selector('title', :content => "Sellers")
  end
  
  it "should have an Affiliates page at '/affiliates'" do
    get '/affiliates'
    response.should have_selector('title', :content => "Affiliates")
  end
  
  it "should have a Terms page at '/terms'" do
    get '/terms'
    response.should have_selector('title', :content => "Terms")
  end
end
