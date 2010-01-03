require 'gcal4ruby'
class GoogleCalendar < ActiveRecord::Base
  has_hashed_id
  has_many :experiments
  
  attr_accessible :login, :password, :name
  
  attr_encrypted :login, :key => ENCRYPTED_ATTR_PASSKEY
  attr_encrypted :password, :key => ENCRYPTED_ATTR_PASSKEY
   
  validates_presence_of :login
  validates_presence_of :password
  validates_presence_of :name
  
  validate :confirm_login
  validate :confirm_calendar
  
  before_save :find_calendar_id
  
  def self.calendars(login, password)
    service = self.get_service()
    unless service == nil
      return GCal4Ruby::Calendar.find(service, :all)
    end
  end
  
  def find_calendar_id
    service = self.get_service()
    if service
    new_calendar = GCal4Ruby::Calendar.find(service, self.name, {:scope => :first})
    self.calendar_id = new_calendar.id
    self.name = new_calendar.title
    end
  end
  
  def calendar_html
    my_calendar = self.calendar
    html = "Error: calendar not found"
    unless my_calendar == nil
      html = my_calendar.to_iframe({:showCalendar => false, :showTimezone => false, :showTitle => false})
      logger.info("Cal: #{html}")
    end
    return html
  end
  
  def confirm_login
    if self.get_service == nil
      errors.add(:login, " or password is not correct")
      return false
    end
    return true
  end
  
  def confirm_calendar
    service = self.get_service()
    if service != nil and !name.blank?
      new_calendar = GCal4Ruby::Calendar.find(service, name, {:scope => :first})
      unless new_calendar == nil
        return true
      end
    end
    errors.add(:name, ": could not find this calendar")
      
    return false
  end
  
  def calendar
    service = self.get_service()
    if service != nil
      my_calendar = GCal4Ruby::Calendar.find(service, self.calendar_id, :first)
      return my_calendar
    end
  end
  
  def add_scheduled_slot(experiment, slot, subject)
    start_time = slot.time
    endtime = start_time + experiment.time_length.minutes
    event = GCal4Ruby::Event.new(calendar)
    event.title = experiment.name + ' - ' + subject.name
    event.content = "An experiment for " + experiment.name \
                  + " was automatically scheduled for this time by the Experiment Signup Tool\n"  \
                  + "Subject: " + subject.name \
                  + "\n\nExperiment Contact " + experiment.user.name + ", " + experiment.user.email
    event.where = experiment.location.human_location
    event.start = start_time
    event.end = endtime
    event.save
  end 
  
  def get_service()
    return GoogleCalendar.get_service(self.login, self.password)
  end
  
  def self.get_service(login, password)
    begin
      service = GCal4Ruby::Service.new
      authenticated = service.authenticate(login, password) 
      return service 
    rescue GCal4Ruby::AuthenticationFailed
    
    rescue GCal4Ruby::HTTPPostFailed
    
    end
    
    return nil
  end
end
