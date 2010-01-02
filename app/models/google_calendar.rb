class GoogleCalendar < ActiveRecord::Base
  has_hashed_id
  has_many :experiments
  
  attr_encrypted :login, :key => ENCRYPTED_ATTR_PASSKEY
  attr_encrypted :password, :key => ENCRYPTED_ATTR_PASSKEY
   
  validates_presence_of :login
  validates_presence_of :password
  validates_presence_of :name
  validates_confirmation_of :password
  validates_uniqueness_of :login
  
  validate :confirm_login
  validate :confirm_calendar
  
  before_save :find_calendar_id
  
  def confirm_login
    return (self.get_service() != nil)  
  end
  
  def find_calendar_id
    service = self.get_service()
    if service
    new_calendar = GCal4Ruby::Calendar.find(service, self.name, {:scope => :first})
    self.calendar_id = new_calendar.id
    end
  end
  
  def confirm_calendar
    service = self.get_service()
    if service
       new_calendar = GCal4Ruby::Calendar.find(service, self.name, {:scope => :first})
    if new_calendar != nil
      return true
    end
    end
    return false
  end
  
  def get_service
    begin
      service = GCal4Ruby::Service.new
      authenticated = service.authenticate(self.login, self.password)   
      return service if authenticated
    rescue AuthenticationFailed
      return nil
    end
    
    return nil
  end
  
  def calendar
    service = self.get_service()
    if service
    my_calendar = GCal4Ruby::Calendar.get(service, self.calendar_id)
    return my_calendar
    end
  end
  
  def add_scheduled_slot(experiment, slot, subject)
    start_time = slot.time
    endtime = start_time + experiment.time.minutes
    event = GCal4Ruby::Event.new(calendar)
    event.title = experiment.name + ' - ' + subject.name
    event.content = "An experiment for " + experiment.name \
                  + " was automatically scheduled for this time by the Experiment Signup Tool\n"  \
                  + "Subject: " + subject.name \
                  + "\n\nExperiment Contact " + experiment.user.name + ", " + experiment.user.email
    event.where = experiment.location.to_h
    event.start = start_time
    event.end = endtime
    event.save
  end
  
end
