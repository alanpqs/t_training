module Admin::MediaHelper
  
  def display_warning(medium)
    if medium.rejected?
      "Rejected"
  elsif medium.unauthorized?
      "Authorization pending"
    end
  end
  
  def select_edit_form(medium)
    if medium.unauthorized?
      link_to medium.medium, edit_admin_authorize_medium_path(medium.id), :title => "Authorize #{medium.medium}"
    elsif medium.rejected?
      medium.medium
    else
      link_to medium.medium, edit_admin_medium_path(medium.id), :title => "Edit #{medium.medium}"
    end
  end
end
