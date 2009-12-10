class Slot < ActiveRecord::Base
    has_hashed_id
  
  belongs_to :experiment
  belongs_to :subject
  
  named_scope :find_by_day, lambda { |d| { :conditions  => { :time  => d.beginning_of_day..d.end_of_day }, :order=>"time" } }
  named_scope :find_by_occupied, { :conditions  => ["subject_id is not NULL"] }
  
  def human_time
    return "---" if time.nil? 
    return time.strftime("%b %e (%a) @ %I:%M %p")
  end
end
