class Experiment < ActiveRecord::Base
    has_hashed_id
    belongs_to :user
    belongs_to :google_calendar
    belongs_to :location
    has_many :slots, :order => :time, :dependent => :destroy
    validates_presence_of     :name
    validates_presence_of     :desc
    validates_presence_of     :user
    validates_presence_of     :location
    validates_numericality_of :time_length, :only_integer => true, :greater_than => 0
    validates_numericality_of :num_subjects, :only_integer => true, :greater_than => 0
    validates_numericality_of :compensation, :only_integer => true, :greater_than => -1
    validates_numericality_of :num_subjects_per_slot, :only_integer => true, :greater_than => 0
  
    def open?
      self.read_attribute(:open)
    end
   
    def is_occupied(day)
      occupied = occupied_slots(day)
      return !occupied.empty?
    end
    
    def occupied_slots(day)
      occupied = Array.new
      slots = Slot.find_by_experiment(self.id).find_by_day(day)
      slots.each do |slot|
        occupied << slot if slot.occupied?
      end
      return occupied
  end

  def filled?
    subject_count = 0
    self.slots.each do |slot|
      subject_count += slot.subjects_count
    end
    return subject_count >= self.num_subjects
  end
  
   def owned_by?(user)
      return user.id == self.user_id
  end
  
  def human_time_length
     return "---" if time_length <= 0 
     hours = time_length.minutes / 1.hours
     minutes = time_length - 60 * hours
     human_arry = []
     if hours > 1
      human_arry << "#{hours} hour"
     elsif hours == 1
      human_arry << "1 hr"
    end
    if minutes > 1
      human_arry << "#{minutes} minutes"
    elsif
      human_arry << "#{minutes} minute"
    end
     return human_arry.join(" and ")
  end
  
  def can_modify?(user)
    return false if user == :false || user == nil
    return (user.id == self.user_id) || user.has_role?(:admin)
  end
end
