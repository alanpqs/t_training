# == Schema Information
# Schema version: 20110218164605
#
# Table name: searchlists
#
#  id          :integer         not null, primary key
#  user_id     :integer
#  focus       :string(255)
#  category_id :integer
#  topics      :string(255)
#  proximity   :integer
#  country_id  :integer
#  region_id   :integer
#  medium_id   :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class Searchlist < ActiveRecord::Base
  
   attr_accessible :user_id, :focus, :category_id, :topics, :proximity, :country_id, :region_id, :medium_id
   
   belongs_to :user
   belongs_to :country
   belongs_to :region
   belongs_to :medium
   belongs_to :category
   
   FOCUS_TYPES = [ "Business", "Job", "Personal", "World", "Fun" ]
   
   validates       :user_id,            :presence     => true
   validates       :focus,              :presence     => true,
                                        :inclusion    => { :in => FOCUS_TYPES }
   validates       :category_id,        :presence     => true
   validates       :proximity,          :numericality => { :only_integer => true, :allow_nil => true }
   validates_associated :country, :allow_nil => true
   validates_associated :region, :allow_nil => true
   validates_associated :medium, :allow_nil => true
   validates_length_of :topics, :maximum => 10, 
                              :too_long => " - the maximum number of actual words you can enter is 10.", 
                              :tokenizer => lambda {|str| str.scan(/\w+/) }
                                  

  def self.all_by_member(user)
    self.find(:all, :conditions => ["user_id = ?", user.id], :order => "created_at") 
  end
  
  def attendance_required?
    if self.medium_id.blank?
      return true
    else
      if self.medium.attendance?
        return true
      else
        return false
      end
    end
  end
  
  def is_schedulable?
    if self.medium_id.blank?
      return true
    else
      if self.medium.scheduled?
        return true
      else
        return false
      end
    end
  end

  def location_descriptor
    @user = User.find(self.user_id)
    @user_country = Country.find(@user.country_id)
    if self.attendance_required?
      unless self.region_id.blank?
        str = "Anywhere in #{self.region.region}"
      else
        unless self.proximity.blank?
          if self.country_id == @user_country.id || self.country_id.blank?
            str = "Anywhere within around #{self.proximity} km"
          else
            str = "Anywhere in #{self.country.name}"
          end
        else
          if self.country_id.blank?
            str = "Set-up error for location"
          else
            str = "Anywhere in #{self.country.name}"
          end
        end
      end
    else
      str = "Not applicable"
    end   
    return str
  end
  
  def adjust_location_search
    if self.attendance_required?
      unless self.region_id.blank?
        self.update_attributes(:country_id => nil, :proximity => nil)
      else
        unless self.country_id.blank?
          if self.country_id != self.user.country_id
            self.update_attribute(:proximity, nil)
          end
        else
          self.update_attribute(:country_id, self.user.country_id)
        end
      end
    else
      self.update_attributes(:country_id => nil, :proximity => nil, :region_id => nil)
    end
  end
  
  def format_string
    if self.medium_id.blank?
      return "Any"
    else
      return self.medium.medium
    end
  end
  
  def self.count_by_member(user)
    nmbr = self.count(:all, :conditions => ["user_id = ?", user.id])
  end
  
  def format_display
    if self.medium_id.blank?
      txt = "Any"
    else
      txt = self.medium.medium
    end
    return txt
  end

end
