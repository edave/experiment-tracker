class Slot < ActiveRecord::Base
    has_hashed_id
  
  belongs_to :experiment
  has_many :appointments
  has_many :subjects, :through => :appointments
  
  validates_presence_of :experiment
  attr_readonly :experiment
  
  #before_save :update_count
  
  named_scope :find_by_day, lambda { |d| {:conditions  => { :time  => d.beginning_of_day_in_zone..(d+1.day).beginning_of_day_in_zone }, :order=>"time" } }
  named_scope :find_by_occupied, lambda { |e| {:conditions => {:appointments_count => 1..e.num_subjects_per_slot, :cancelled => false, :experiment_id => e.id}, :order => 'time'} }
  named_scope :find_by_available, lambda { |e| {:conditions => {:appointments_count => 0...e.num_subjects_per_slot,:cancelled => false, :experiment_id => e.id, :time => (Time.zone.now+e.slot_close_time.minutes)..(Time.zone.now + 1.years)}, :order => 'time'} }
  named_scope :find_by_full, lambda { |e| {:conditions => {:appointments_count => e.num_subjects_per_slot, :cancelled => false, :experiment_id => e.id}, :order => 'time'} }
  named_scope :find_by_experiment, lambda { |e| { :conditions => {:experiment_id => e}, :include => :experiment}}
  
  validate :limit_subjects
  
  def occupied?
    return !self.appointments.empty?
  end
  
  def filled?
    return self.appointments.count >= self.experiment.num_subjects_per_slot
  end
  
  def limit_subjects
    unless self.appointments.count <= self.experiment.num_subjects_per_slot
      errors.add("slot", " is filled to capacity")
      return false
    end
    return true
  end
  
  def human_time
    return "---" if time.nil? 
    return time.strftime("%b %e (%a) @ %I:%M %p")
  end
  
  def update_count
    update_attribute(:subjects_count, self.subjects.count)
  end
end
