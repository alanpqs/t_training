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
  
  before_validation(:on => :create) do
    self.submitted_name = self.category
    self.submitted_group = self.target
  end

  cat_regex = /\A(\w+(\s?([&]\s)?))+\Z/
  
  TARGET_TYPES = [ "Business", "Job", "Personal", "World", "Fun" ]

  belongs_to :user
  has_many   :resources
  
  validates :category,        :presence       => true,
                              :length         => { :maximum => 30 },
                              :uniqueness     => { :scope => :target, :case_sensitive => false },
                              :format         => { :with => cat_regex, 
                                                   :message => "is invalid - please avoid commas, dashes,
                                                                periods and double spaces" }   
  validates :target,          :presence       => true,
                              :inclusion      => { :in => TARGET_TYPES }
  validates :message,         :length         => { :maximum => 0, :if => :first_time_authorized?, 
                                          :message => "should be empty if you are authorizing the category" }
  validates :user_id,         :presence       => true
  validates :submitted_name,  :presence       => true
  validates :submitted_group, :presence       => true
   
   
  #DISPLAY METHODS
  
  def self.list_all_by_target(target)
    self.find(:all, :conditions => ["target = ?", target], :order => "authorized, message_sent, category")
  end
  
  def self.all_authorized_by_target(target)
    self.find(:all, :conditions => ["target = ? and authorized = ?", target, true], :order => "category")
  end
  
  def self.all_approvals_needed
    self.find(:all, :conditions => ["authorized = ?", false])
  end
  
  def approval_status
    if self.authorized == true
      return ""
    elsif self.message_sent == true
      return "rejected"
    else
      return "new"
    end
  end
  
  def rejected?
    self.authorized == false && self.message_sent == true
  end
  
  #select method to pick all groups except currently selected
  
  def self.list_groups_except(target)
    t = self::TARGET_TYPES
    list = []
    5.times do |n|
      list << "#{t[n]}" unless "#{t[n]}" == target
    end
    return list
  end
  
  
  #DETERMINES WHETHER CATEGORY APPROVALS ARE REQUIRED
  
  def self.approvals_needed?
    found = self.count(:all, :conditions => ["authorized = ?", false])
    found >0
  end
  
  #METHODS WHEN APPROVING OR REJECTING NEW CATEGORIES
  
  def first_time_authorized?
    self.authorized == true && self.message_sent == false
  end
  
  #email responses required in 3 cases
    #New Rejection
    #Authorization but with changes
    #Switch from Rejected to Authorized
      #(Not when previously Authorized to Rejected - which could only occur if Category unused.)
  
  def should_mail_submission_message?                   # -> email rejection message
    self.authorized == false && (self.message_sent == false && !self.message.blank?)
  end
  
  def should_mail_authorization_message?(name, group)   # -> email: authorized but changed
    self.authorized == true && self.submission_change?(name, group) && self.message_sent == false
  end
  
  def should_mail_auth_mess_after_rej?(name, group)   # -> email: now authorized but changed
    self.authorized == true && self.submission_change?(name, group) && self.message_sent == true
  end
  
  def now_authorized_after_rejection?    #email sent
    self.authorized == true && !self.message.blank?
  end
  
  def now_rejected_after_authorized(previous_authorization)   # -> no email required
    self.authorized == false && previous_authorization == true
  end
  
  #METHODS TO DETERMINE FLASH MESSAGES
  
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
  
  def in_group
    self.target
  end
  
  def submission_change?(name, group)
    self.name_change?(name) || self.group_change?(group)
  end
  
  def success_message(auth1, sent, name, group)
    
    @cat = name
    
    message =  ["'#{@cat}' authorized without change - no email confirmation sent.",         #0
                "'#{@cat}' updated.",                                                        #1      
                "'#{@cat}' changed to rejected - no email sent.",                            #2
                "'#{@cat}' rejected and email sent.",                                        #3
                "'#{@cat}' changed to authorized - email confirmation sent.",                #4
                "'#{@cat}' still rejected but updated.",                                     #5
                "'#{@cat}' updated but still unauthorized - no rejection email sent.",       #6
                "'#{@cat}' changed to unauthorized - but no rejection email sent.",          #7
                "'#{@cat}' authorized - email change-notification sent."                     #8
                ]         
                
                
    
    if auth1 == false && self.authorized == true && !submission_change?(name, group) && sent == false
      m = message[0]
    elsif auth1 == false && self.authorized == true && submission_change?(name, group) && sent == false
      m = message[8]
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
  
    def make_submissions
      self.submitted_name = self.category
      self.submitted_group = self.target
    end               
end
