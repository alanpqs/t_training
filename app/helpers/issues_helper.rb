module IssuesHelper
  
  def doll_conversion
    unless @issue.currency == "USD"
      unless @issue.convert_to_dollars(@vendor.id) == "Unknown"
        "(approx US$ #{@issue.convert_to_dollars(@vendor.id)})"
      end
    end   
  end
end
