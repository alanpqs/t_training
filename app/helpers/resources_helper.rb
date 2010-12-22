module ResourcesHelper
  
  def display_status
    if !@resource.vendor.verified?
      "This resource will not be seen by the public until the vendor has been verified.  An authorization request has
       been sent to the vendor email address."
    else
      if @resource.hidden?
        "This resource is hidden from public view."
      else
        "This resource is displayed to the public."
      end
    end
  end
end
