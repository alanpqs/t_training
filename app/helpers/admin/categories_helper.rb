module Admin::CategoriesHelper
  
  def pager(value)
    link_to @other_groups[value], admin_categories_path(:id => @other_groups[value])
  end
end
