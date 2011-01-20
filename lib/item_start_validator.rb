class ItemStartValidator < ActiveModel::EachValidator  
  def validate_each(object, attribute, value)  
    value = Time.now
    if value < attribute  
      object.errors[attribute] << (options[:message] || "must not be after the end-date")  
    end  
  end  
end  
