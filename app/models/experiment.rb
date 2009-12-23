class Experiment < ActiveRecord::Base
    has_hashed_id
    belongs_to :user
    has_many :slots
    validates_presence_of     :name
    validates_presence_of     :desc
    
    def occupied_slots(day)
      return Slot.find_by_experiment(self.id).find_by_occupied.find_by_day(day)
  end
  
   def owned_by?(user)
      return user.id == self.user_id
  end
  
  def human_time_length
     return time_length
  end
  
  def can_modify?(user)
    return (user.id == self.user_id) || user.admin?
  end
end
