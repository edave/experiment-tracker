class Experiment < ActiveRecord::Base
    has_hashed_id
    belongs_to :user
    
    def occupied_slots(day)
      return Slot.find_by_experiment(self.id).find_by_occupied.find_by_day(day)
    end
end
