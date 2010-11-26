# == Schema Information
# Schema version: 20101116103755
#
# Table name: categories
#
#  id              :integer         not null, primary key
#  category        :string(255)
#  target          :string(255)
#  authorized      :boolean
#  user_id         :integer
#  message         :text
#  message_sent    :boolean
#  submitted_name  :string(255)
#  submitted_group :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

class Category < ActiveRecord::Base
  
  attr_accessible :category, :target, :authorized, :user_id, :message, :submitted_name, :submitted_group
  
  before_update :check_authorized
  
  cat_regex = /\A(\w+(\s?([&]\s)?))+\Z/
  
  TARGET_TYPES = [ "Business", "Job", "Personal", "World", "Fun" ]

  belongs_to :user
  
  validates :category,        :presence       => true,
                              :length         => { :maximum => 30 },
                              :uniqueness     => { :case_sensitive => false },
                              :format         => { :with => cat_regex, 
                                                   :message => "is invalid - please avoid commas, dashes,
                                                                periods and double spaces" }   
  validates :target,          :presence       => true,
                              :inclusion      => { :in => TARGET_TYPES }
  validates :user_id,         :presence       => true
  validates :submitted_name,  :presence       => true
  validates :submitted_group, :presence       => true
   
   
  def self.list_all_by_target(target)
    self.find(:all, :conditions => ["target = ?", target], :order => "authorized, message_sent, category")
  end
  
  def approval_status
    if self.authorized == true
      return ""
    elsif self.message_sent == true
      return "rejected"
    else
      return "NEEDED"
    end
  end
  
  def should_mail_submission_message?
    self.authorized == false && (self.message_sent == false && !self.message.blank?)
  end
  
  def should_mail_authorization_message?(name, group)
    self.authorized == true && self.submission_change?(name, group) && self.message_sent == false
  end
  
  def name_change?(name)
    name != self.category
  end
  
  def report_name_change(name)
    statement = "Name: changed from '#{self.submitted_name}' to '#{self.category}'."
    return statement if self.name_change?(name)
    return nil
  end
  
  def group_change?(group)
    group != self.target
  end
  
  def report_group_change(group)
    statement = "Group: changed from '#{self.submitted_group}' to '#{self.target}'."
    return statement if self.group_change?(group)
    return nil
  end
  
  def submission_change?(name, group)
    self.name_change?(name) || self.group_change?(group)
  end
  
  def success_message(auth1, sent, name, group)
    
    @cat = name
    
    message =  ["'#{@cat}' authorized and email confirmation sent.",                         #0
                "'#{@cat}' updated.",                                                        #1      
                "'#{@cat}' changed to rejected and email sent.",                             #2
                "'#{@cat}' rejected and email sent.",                                        #3
                "'#{@cat}' changed to authorized - email confirmation sent.",                #4
                "'#{@cat}' still rejected but updated.",                                     #5
                "'#{@cat}' updated but still unauthorized - no rejection email sent.",       #6
                "'#{@cat}' changed to unauthorized - but no rejection email sent."]          #7
                
    
    if auth1 == false && self.authorized == true && sent == false
      m = message[0]
    elsif auth1 == false && self.authorized == true && sent == true
      m = message[4]
    elsif auth1 == true && self.authorized == true
      m = message[1]
    elsif auth1 == true && self.authorized == false && !self.message.blank?
      m = message[2]
    elsif auth1 == true && self.authorized == false && self.message.blank?
      m = message[7] 
    elsif auth1 == false && self.authorized == false && sent == false && !self.message.blank?
      m = message[3]
    elsif auth1 == false && self.authorized == false && sent == false && self.message.blank?
      m = message[6]
    elsif auth1 == false && self.authorized == false && sent == true
      m = message[5] 
    end
    
    n = report_name_change(name)
    g = report_group_change(group)
    
    if n.nil?
      if g.nil?
        return "#{m}"
      else
        return "#{m}  #{g}"
      end
    else
      if g.nil?
        return "#{m}  #{n}"
      else
        return "#{m}  #{n}  #{g}"
      end
    end 
  end
  
  private
    
    def check_authorized
      
      @name = self.submitted_name
      @group = self.submitted_group
      
      if self.authorized == true
        self.update_attribute(:message, nil) if !self.message.blank?
        self.update_attribute(:message_sent, false) unless self.submission_change?(@name, @group)
      end
    end                               
end
