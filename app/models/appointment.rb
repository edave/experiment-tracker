class Appointment < ActiveRecord::Base
  belongs_to :slot, :counter_cache => true
  belongs_to :subject, :counter_cache => true, :dependent => :destroy
  has_one :experiment, :through => :slot
  validates_uniqueness_of :subject_id, :scope => [:slot_id]

  # ACL9 authorization support
  acts_as_authorization_object

end
