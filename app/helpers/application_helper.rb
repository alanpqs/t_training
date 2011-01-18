module ApplicationHelper

  include ActsAsTaggableOn::TagsHelper
  
  def logo
    image_tag("logo.png", :alt => "Tickets for Training", :class => "round")  
  end

  def title
    base_title = "Tickets for Training"
    if @title.nil?
      base_title
    else
      "#{base_title} | #{@title}"
    end
  end

  def default_date(date_field)
    date_field.strftime '%d-%b-%Y'
  end
  
  def submit_button(label)
    submit_tag label, :class => "action_round"
  end
  
  def drop_changes(route)
    link_to "(drop changes)", route
  end
  
  def back_to_input
    link_to "(return to input form)", session[:return_to]
  end
  
  def previous_page(admin_route, user_route)
    if current_user.admin?
      path = admin_route
    else
      path = user_route
    end
    
    link_to "(previous page)", path
    
  end
  
  def display_date(date)
    date.strftime('%d-%b-%y')
  end
end
