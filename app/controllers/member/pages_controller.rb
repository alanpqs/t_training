class Member::PagesController < ApplicationController
  
  def home
    @title = "Member home-page"
  end
  
  def focus
    @user = current_user
    @title = "What's your main aim?"
    @tag_name = "Continue"
    @targets = Category::TARGET_TYPES
  end
end
