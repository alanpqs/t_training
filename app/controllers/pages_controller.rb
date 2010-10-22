class PagesController < ApplicationController
  def home
    @title = "Home"
  end

  def why_register
    @title = "Why Register"
  end
  
  def about
    @title = "About"
  end
  
  def faqs
    @title = "FAQs"
  end
  
  def find_training
    @title = "Find Training"
  end
  
  def signup
    @title = "Signup"
  end
  
  def login
    @title = "Login"
  end

end
