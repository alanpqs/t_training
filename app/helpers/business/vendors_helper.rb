module Business::VendorsHelper
  
  def other_users
    if @vendor.count_reps_excluding_self == 0
      "No other colleagues are"
    elsif @vendor.count_reps_excluding_self == 1
      "One other colleague is"
    else 
      "#{@vendor.count_reps_excluding_self} other colleagues are"
    end
  end
  
  def review_msg
    if @vendor.show_reviews?
      "(Displayed. To turn off, see below)"
    else
      "(Not displayed. To turn on, see below)"
    end
  end
end
