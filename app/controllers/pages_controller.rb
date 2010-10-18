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

end
