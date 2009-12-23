class Slot < ActiveRecord::Base
    has_hashed_id
  
  belongs_to :experiment
  belongs_to :subject
  
  named_scope :find_by_day, lambda { |d| {:conditions  => { :time  => d.beginning_of_day_in_zone..(d+1.day).beginning_of_day_in_zone }, :order=>"time" } }
  named_scope :find_by_occupied, lambda { |e| {:conditions  => ["subject_id is not NULL AND cancelled = ? and experiment_id = ?", false, e.id] } }
  named_scope :find_by_experiment, lambda { |e| { :conditions => {:experiment_id => e}, :include => :experiment}}
  
  def occupied?
    return !self.subject.nil?
  end
  
  def human_time
    return "---" if time.nil? 
    return time.strftime("%b %e (%a) @ %I:%M %p")
  end
end
