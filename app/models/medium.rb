# == Schema Information
# Schema version: 20110111104631
#
# Table name: media
#
#  id                :integer         not null, primary key
#  medium            :string(255)
#  authorized        :boolean
#  user_id           :integer
#  rejection_message :text
#  created_at        :datetime
#  updated_at        :datetime
#  scheduled         :boolean
#

class Medium < ActiveRecord::Base
  
  attr_accessible :medium, :authorized, :user_id, :rejection_message, :scheduled
  
  before_destroy :has_been_rejected?
  
  belongs_to  :user
  has_many    :resources
  
  validates       :medium,            :presence     => true,
                                      :length       => { :maximum => 30 },
                                      :uniqueness   => { :case_sensitive => false }
  validates       :user_id,           :presence     => true,
                                      :numericality => true
  validates       :rejection_message, :length       => { :maximum => 0, :if => :authorization_on?,
                                              :message => "should be empty if you are authorizing the medium" }
  
  def rejected?
    !self.rejection_message.blank? && self.authorized == false
  end
  
  def unauthorized?
    self.rejection_message.blank? && self.authorized == false
  end
  
  def warning?
    self.unauthorized? || self.rejected?
  end
  
  def authorized_with_changes?(previously_authorized, original, modified)
    (self.authorized == true) && (previously_authorized == false) && (original != modified)
  end
  
  def authorization_on?
    self.authorized == true
  end
  
  def self.all_authorized
    self.find(:all, :conditions => ["authorized = ?", true], :order => "medium")
  end
  
  def self.approvals_needed?
    found = self.count(:all, :conditions => ["authorized = ?", false])
    found >0
  end
  
  private
  
    def has_been_rejected?
      !self.rejection_message.blank? && self.authorized == false
    end
end
