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
  
end
