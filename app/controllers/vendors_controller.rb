class VendorsController < ApplicationController
  
  
  def confirm
    @vcode = params[:code]
    @vendor = Vendor.find_by_verification_code(@vcode)
    if @vendor.nil?
      flash[:error] = "You tried to confirm a new vendor, but the verification code could not be found.  
          Perhaps the vendor has already been authenticated.  Or if it's been longer than 72 hours since 
          you received the verification mail, your vendor application may have been deleted - so just 
          enter the details again."
    else
      @vendor.update_attributes(:verified => true, :verification_code => nil)
      Credit.create(:vendor_id => @vendor.id, :quantity => 50, :cents => 0, :note => "New vendor bonus")
      flash[:success] = "Thank you. #{@vendor.name} is now listed, and you can start adding your 
            training products and services. We've also added 50 free credits to your account, so that you
            can try out our unique Tickets for Training Scheme.  For more details click on 'Tickets'
            in the left-hand menu." 
    end
    
    select_home_path
  end
end
