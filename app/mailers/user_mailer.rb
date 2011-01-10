class UserMailer < ActionMailer::Base
  
  default :from => "alanpqs@gmail.com"
  
  def category_not_authorized(user, category)
    @member = user
    @category = category
    mail( :to       => "#{@member.name} <#{@member.email}>", 
          :subject  => "'Tickets for Training': your Category submission")
  
  end
  
  def category_authorized_with_changes(user, category)
    @member = user
    @category = category
    mail( :to       => "#{@member.name} <#{@member.email}>", 
          :subject  => "'Tickets for Training': your Category submission")
  end
  
  def category_now_accepted(user, category)
    @member = user
    @category = category
    mail( :to       => "#{@member.name} <#{@member.email}>", 
          :subject  => "'Tickets for Training': your Category now accepted")
  end
  
  def category_now_accepted_with_changes(user, category)
    @member = user
    @category = category
    mail( :to       => "#{@member.name} <#{@member.email}>", 
          :subject  => "'Tickets for Training': your Category now accepted")
  end
  
  def medium_accepted_with_changes(user, original, modification)
    @user = user
    @original = original
    @modification = modification
    mail( :to       => "#{@user.name} <#{@user.email}>", 
          :subject  => "'Tickets for Training': Training Format accepted - but changed")
    
  end
  
  def medium_rejected(user, submission)
    @user = user
    @medium = submission
    mail( :to       => "#{@user.name} <#{@user.email}>", 
          :subject  => "'Tickets for Training': Training Format not accepted")
  end
  
  def new_password(user, pass)
    @user = user
    @password = pass
    unless Rails.env.production?
      @url = "http://localhost:3000/login"
    else
      @url = "http://fierce-earth-31.heroku.com/login"
    end
    mail( :to       => "#{@user.name} <#{@user.email}>", 
          :subject  => "'Tickets for Training': your new password")
  end
end
