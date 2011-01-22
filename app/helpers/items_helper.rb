module ItemsHelper
  
  def dollar_conversion
    unless @item.currency == "USD"
      unless @item.conversion_to_dollars(@vendor.id) == "Unknown"
        "(approx US$ #{@item.conversion_to_dollars(@vendor.id)})"
      end
    end   
  end
end
