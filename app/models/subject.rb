class Subject < ActiveRecord::Base
  has_hashed_id
  
  attr_encrypted :name, :key => ENCRYPTED_ATTR_PASSKEY
  attr_encrypted :email, :key => ENCRYPTED_ATTR_PASSKEY
  attr_encrypted :phone_number, :key => ENCRYPTED_ATTR_PASSKEY
  
  has_many :appointments
  has_many :slots, :through => :appointments, :order => :time
  
  before_validation :clean_phone_number
  
  validates_presence_of :name
  validates_length_of :phone_number, :minimum => 10, :allow_blank => true, :allow_nil => true
  
  validates_email :email, :unique => true, :encrypted => true
  
  def clean_phone_number
    unless self.phone_number.nil?
     self.phone_number = self.phone_number.gsub(/[^\d]/,'')
    end
  end
  
end
