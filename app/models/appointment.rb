class Appointment < ActiveRecord::Base
  belongs_to :slot, :counter_cache => true
  belongs_to :subject, :counter_cache => true, :dependent => :destroy
  has_one :experiment, :through => :slot
  validates_uniqueness_of :subject_id, :scope => [:slot_id]

end
