module Business::VendorsHelper
  
  def other_users
    if @vendor.count_reps_excluding_self == 0
      "0 other colleagues are"
    elsif @vendor.count_reps_excluding_self == 1
      "1 other colleague is"
    else 
      "#{@vendor.count_reps_excluding_self} other colleagues are"
    end
  end
end
