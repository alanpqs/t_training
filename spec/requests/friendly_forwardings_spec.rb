 require 'spec_helper'
 
 describe "FriendlyForwardings" do
   
   it "should forward to the requested page after login" do
     user = Factory(:user)
     visit edit_user_path(user)
     #Not logged in - automatic redirect to log in page
     fill_in :email,        :with => user.email
     fill_in :password,     :with => user.password
     click_button
     #Automatically follows redirect again to page requested
     response.should render_template('users/edit') 
   end
 end
