module ApplicationHelper

  def title
    base_title = "Tickets for Training"
    if @title.nil?
      base_title
    else
      "#{base_title} | #{@title}"
    end
  end

end
