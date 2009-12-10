class Slot < ActiveRecord::Base
    has_hashed_id
  
  belongs_to :experiment
  belongs_to :subject
  
  def human_time
    return "---" if time.nil? 
    return time.strftime("%b %e (%a) @ %I:%M %p")
  end
end
