class VendorMailer < ActionMailer::Base
  
  default :from => "alanpqs@gmail.com"
  
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
