module ResourcesHelper
  
  def display_status
    if !@resource.vendor.verified?
      "Until the vendor has been verified, this resource will not be seen by the public, and you won't be 
       allowed to set a schedule.  We've sent an authorization request to your vendor email address.  Please 
       reply."
    else
      if @resource.hidden?
        "NO LONGER AVAILABLE."
      else
        if @resource.has_current_events?
          "In progress"
        elsif @resource.has_scheduled_events?
          "Next scheduled"
        else
          "NONE PLANNED"
        end  
      end
    end
  end
  
  def description_handler
    if @resource.description.blank?
      return "We strongly recommend that you add a description of your resource.  Use it as a sales pitch: what
       special features does it have, and how will people benefit?"
    else 
      @resource.description 
    end  
  end
end
