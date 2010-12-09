class VendorsController < ApplicationController
  
  def confirm
    @vcode = params[:code]
    @vendor = Vendor.find_by_verification_code(@vcode)
    if @vendor.verified == false
      @vendor.update_attributes(:verified => true, :verification_code => nil)
    end
    flash[:success] = "Thank you. #{@vendor.name} is now listed, and you can start adding your training products and services."
    redirect_to login_path
  end
end
