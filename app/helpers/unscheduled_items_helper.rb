module UnscheduledItemsHelper 
  
  def availability_status
    unless @resource.schedulable?
      if @item.start <= Date.today
        if @item.filled?
          return "Not available at present"
        else
          return "Available now"
        end
      else
        if @item.filled?
          return "Not yet available; release date is #{display_date(@item.start)}"
        else
          return "Order now; scheduled release date #{display_date(@item.start)}"
        end
      end
    else
      return nil
    end
  end
end
