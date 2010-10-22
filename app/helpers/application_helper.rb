module ApplicationHelper

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

end
