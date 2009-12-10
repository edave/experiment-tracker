class Subject < ActiveRecord::Base
  has_hashed_id
  
  has_one :slot
  
  before_validation :clean_phone_number
  
  validates_presence_of     :name
  validates_length_of :phone_number, :minimum => 10, :allow_blank => true, :allow_nil => true
  
  validates_email           :email, :unique => true
  
  
  
  def clean_phone_number
    unless self.phone_number.nil?
     self.phone_number = self.phone_number.gsub(/[^\d]/,'')
    end
  end
  
end
