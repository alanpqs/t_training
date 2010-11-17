class PagesController < ApplicationController
  
  before_filter :authenticate,    :only => [:categories_admin]
  before_filter :admin_user,      :only => [:categories_admin]
  
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
  
  def buyers
    @title = "Buyers"
  end
  
  def sellers
    @title = "Sellers"
  end
  
  def affiliates
    @title = "Affiliates"
  end
  
  def terms
    @title = "Terms"
  end
  
  def categories_admin
    @title = "Training categories"
  end
end
