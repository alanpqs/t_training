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
  
  def vendor_confirmation(vendor)
    @vendor = vendor
    @v_code = @vendor.verification_code
    unless Rails.env.production?
      @url = "http://localhost:3000/confirm/#{@v_code}"
    else
      @url = "http://fierce-earth-31.heroku.com/confirm/#{@v_code}"
    end
    mail( :to       => "#{vendor.name} <#{vendor.email}>", 
          :subject  => "'Tickets for Training': Vendor Application")
  end
end
